//
//  InventoryKit.m
//  InventoryKit
//
//  Created by Aubrey Goodman on 10/25/09.
//  Copyright 2009 Migrant Studios LLC. All rights reserved.
//

#import "InventoryKit.h"
#import "IKPaymentTransactionObserver.h"


@interface InventoryKit (private)

+(IKPaymentTransactionObserver*)sharedObserver;
+(void)restoreTransitionProducts;
+(void)activateBundle:(NSString*)bundleKey;

@end


@implementation InventoryKit

+ (void)prepareTransitionProducts
{
	NSArray* tTransitionProducts = [[NSUserDefaults standardUserDefaults] objectForKey:kTransitionProductsKey];
	if( tTransitionProducts==nil ) {
		NSString* pathToProductKeys = [[NSBundle mainBundle] pathForResource:@"TransitionProducts" ofType:@"plist"];
		tTransitionProducts = [NSArray arrayWithContentsOfFile:pathToProductKeys];
		if( tTransitionProducts==nil ) {
			NSLog(@"Unable to resolve products from file: TransitionProducts.plist");
		}else{
			[[NSUserDefaults standardUserDefaults] setObject:tTransitionProducts forKey:kTransitionProductsKey];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}
	}
}

+ (bool)productActivated:(NSString*)productKey
{
	bool tExists = false;
	
	NSUserDefaults* tDefaults = [NSUserDefaults standardUserDefaults];
	NSArray* tActivatedProducts = [tDefaults objectForKey:kActivatedProductsKey];
	if( tActivatedProducts!=nil ) {
		@try {
			tExists = [tActivatedProducts containsObject:productKey];
		}
		@catch (NSException * e) {
			NSLog(@"InventoryKit: Encountered unexpected object");
		}
	}
	
	return tExists;
}

+ (void)activateProduct:(NSString*)productKey
{
	if( [productKey hasSuffix:@"bundle"] ) {
		[self activateBundle:productKey];
	}else{
		NSUserDefaults* tDefaults = [NSUserDefaults standardUserDefaults];
		NSArray* tOldActivatedProducts = [tDefaults objectForKey:kActivatedProductsKey];
		
		NSMutableArray* tActivatedProducts = [[NSMutableArray alloc] initWithArray:tOldActivatedProducts];
		[tActivatedProducts addObject:[NSString stringWithString:productKey]];
		[tDefaults setObject:tActivatedProducts forKey:kActivatedProductsKey];
		[tDefaults synchronize];
		[tActivatedProducts release];
	}
}

+ (void)deactivateProduct:(NSString *)productKey
{
	NSUserDefaults* tDefaults = [NSUserDefaults standardUserDefaults];
	NSArray* tOldActivatedProducts = [tDefaults objectForKey:kActivatedProductsKey];
	
	NSMutableArray* tActivatedProducts = [[NSMutableArray alloc] init];
	for (NSString* tProductKey in tOldActivatedProducts) {
		if( ! [tProductKey isEqualToString:productKey] ) {
			[tActivatedProducts addObject:tProductKey];
		}
	}
	[tDefaults setObject:tActivatedProducts forKey:kActivatedProductsKey];
	[tDefaults synchronize];
	[tActivatedProducts release];
}

+ (void)activateBundle:(NSString*)bundleKey
{
	NSString* tPath = [[NSBundle mainBundle] pathForResource:@"IKBundles" ofType:@"plist"];
	NSDictionary* tBundles = [NSDictionary dictionaryWithContentsOfFile:tPath];
	NSArray* tBundleProducts = [tBundles objectForKey:bundleKey];
	
	NSUserDefaults* tDefaults = [NSUserDefaults standardUserDefaults];
	NSArray* tOldActivatedProducts = [tDefaults objectForKey:kActivatedProductsKey];
	NSMutableArray* tActivatedProducts = [[NSMutableArray alloc] initWithArray:tOldActivatedProducts];

	for (NSString* tProductKey in tBundleProducts) {
		[tActivatedProducts addObject:tProductKey];
	}
	
	[tDefaults setObject:tActivatedProducts forKey:kActivatedProductsKey];
	[tDefaults synchronize];
	
	[tActivatedProducts release];
}

+ (void)registerWithPaymentQueue
{
	
	[[SKPaymentQueue defaultQueue] addTransactionObserver:[InventoryKit sharedObserver]];
}

+ (void)purchaseProduct:(NSString*)productKey delegate:(id<IKPurchaseDelegate>)delegate
{
	NSLog(@"Submitting %@ to the payment queue",productKey);
	[[InventoryKit sharedObserver] addPurchaseDelegate:delegate productIdentifier:productKey];

	SKPayment* tPayment = [SKPayment paymentWithProductIdentifier:productKey];
	[[SKPaymentQueue defaultQueue] addPayment:tPayment];
}

+ (void)restoreProducts:(id<IKRestoreDelegate>)delegate
{
	if( [SKPaymentQueue canMakePayments] ) {
		NSLog(@"Requesting product restore");
		[[InventoryKit sharedObserver] setRestoreDelegate:delegate];
		
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:kActivatedProductsKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[InventoryKit restoreTransitionProducts];
		
		[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
	}else{
		UIAlertView* tAlert = [[[UIAlertView alloc] initWithTitle:@"Service Unavailable" 
							   message:@"Please try again later" 
							   delegate:nil
							   cancelButtonTitle:nil 
								otherButtonTitles:@"OK",nil] autorelease];
		[tAlert show];
	}
}

#pragma mark private

+ (IKPaymentTransactionObserver*)sharedObserver
{
	static IKPaymentTransactionObserver* instance;
	if( instance==nil ) {
		instance = [[IKPaymentTransactionObserver alloc] init];
	}
	return instance;
}

+ (void)restoreTransitionProducts
{
	NSUserDefaults* tDefaults = [NSUserDefaults standardUserDefaults];
	NSArray* tActivatedProducts = [tDefaults objectForKey:kActivatedProductsKey];
	if( tActivatedProducts==nil ) {
		NSArray* tTransitionProducts = [tDefaults objectForKey:kTransitionProductsKey];
		[tDefaults setObject:[NSArray arrayWithArray:tTransitionProducts] forKey:kActivatedProductsKey];
		[tDefaults synchronize];
	}
}


@end
