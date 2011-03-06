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
+(BOOL)subscriptionActive:(NSString*)productKey;
@end


@implementation InventoryKit

#pragma mark Shared

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

+ (BOOL)productActivated:(NSString*)productKey
{
	if( [self isSubscriptionProduct:productKey] ) {
		return [self subscriptionActive:productKey];
	}else{
		BOOL tExists = NO;
		
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
}

+ (BOOL)isSubscriptionProduct:(NSString*)productKey
{
	NSDictionary* tSusbcriptionProducts = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"IKSubscriptionProducts" ofType:@"plist"]];
	if( [[tSusbcriptionProducts allKeys] containsObject:productKey] ) {
		return YES;
	}
	return NO;
}

+ (BOOL)isConsumableProduct:(NSString*)productKey
{
	NSDictionary* tConsumableProducts = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"IKConsumableProducts" ofType:@"plist"]];
	if( [[tConsumableProducts allKeys] containsObject:productKey] ) {
		return YES;
	}
	return NO;
}

+ (void)setApiToken:(NSString*)aApiToken
{
	static NSString* sApiToken;
	[sApiToken release];
	sApiToken = [aApiToken retain];
}

+ (void)useSandbox:(BOOL)sandbox
{
	static BOOL sUseSandbox;
	sUseSandbox = sandbox;
}

+ (void)deactivateProduct:(NSString *)productKey
{
	NSUserDefaults* tDefaults = [NSUserDefaults standardUserDefaults];

	if( [self isSubscriptionProduct:productKey] ) {
		NSDictionary* tOldSubscriptionProducts = [tDefaults objectForKey:kSubscriptionProductsKey];
		
		NSMutableDictionary* tSubscriptionProducts = [[NSMutableDictionary alloc] initWithDictionary:tOldSubscriptionProducts];
		[tSubscriptionProducts removeObjectForKey:productKey];
		[tDefaults setObject:tSubscriptionProducts forKey:kSubscriptionProductsKey];
		[tSubscriptionProducts release];
	}else{
		NSArray* tOldActivatedProducts = [tDefaults objectForKey:kActivatedProductsKey];
		
		NSMutableArray* tActivatedProducts = [[NSMutableArray alloc] init];
		for (NSString* tProductKey in tOldActivatedProducts) {
			if( ! [tProductKey isEqualToString:productKey] ) {
				[tActivatedProducts addObject:tProductKey];
			}
		}
		[tDefaults setObject:tActivatedProducts forKey:kActivatedProductsKey];
		[tActivatedProducts release];
	}
	
	[tDefaults synchronize];
}

#pragma mark TransitionKit

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

#pragma mark Non-Consumables

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

#pragma mark Consumables

+(void)activateProduct:(NSString*)productKey quantity:(int)aQuantity
{
	NSUserDefaults* tDefaults = [NSUserDefaults standardUserDefaults];
	NSDictionary* tOldConsumableProducts = [tDefaults objectForKey:kConsumableProductsKey];
	
	NSMutableDictionary* tConsumableProducts = [[NSMutableDictionary alloc] initWithDictionary:tOldConsumableProducts];
	NSNumber* tOldQuantity = [tConsumableProducts objectForKey:productKey];
	NSNumber* tQuantity = nil;
	if( tOldQuantity==nil ) {
		tQuantity = [NSNumber numberWithInt:aQuantity];
	}else{
		tQuantity = [NSNumber numberWithInt:[tOldQuantity intValue]+aQuantity];
	}
	[tConsumableProducts setObject:tQuantity forKey:productKey];
	
	[tDefaults setObject:tConsumableProducts forKey:kConsumableProductsKey];
	[tDefaults synchronize];

	[tConsumableProducts release];
}

+(int)quantityAvailableForProduct:(NSString*)productKey
{
	NSDictionary* tConsumableProducts = [[NSUserDefaults standardUserDefaults] objectForKey:kConsumableProductsKey];
	if( tConsumableProducts ) {
		NSNumber* tQuantity = [tConsumableProducts objectForKey:productKey];
		if( tQuantity ) {
			return [tQuantity intValue];
		}
	}
	return 0;
}

+(BOOL)canConsumeProduct:(NSString*)productKey quantity:(int)aQuantity
{
	int tQuantityAvailable = [self quantityAvailableForProduct:productKey];
	if( tQuantityAvailable>=aQuantity ) {
		return YES;
	}
	return NO;
}

+(void)consumeProduct:(NSString*)productKey quantity:(int)aQuantity
{
	NSUserDefaults* tDefaults = [NSUserDefaults standardUserDefaults];
	NSDictionary* tOldConsumableProducts = [tDefaults objectForKey:kConsumableProductsKey];
	
	NSMutableDictionary* tConsumableProducts = [[NSMutableDictionary alloc] initWithDictionary:tOldConsumableProducts];
	NSNumber* tOldQuantity = [tConsumableProducts objectForKey:productKey];
	NSNumber* tQuantity = [NSNumber numberWithInt:[tOldQuantity intValue]-aQuantity];
	[tConsumableProducts setObject:tQuantity forKey:productKey];
	
	[tDefaults setObject:tConsumableProducts forKey:kConsumableProductsKey];
	[tDefaults synchronize];
	
	[tConsumableProducts release];
}

#pragma mark Subscriptions

+(void)activateProduct:(NSString*)productKey expirationDate:(NSDate*)aExpirationDate
{
	NSUserDefaults* tDefaults = [NSUserDefaults standardUserDefaults];
	NSDictionary* tOldSubscriptionProducts = [tDefaults objectForKey:kSubscriptionProductsKey];
	NSMutableDictionary* tSubscriptionProducts = [[NSMutableDictionary alloc] initWithDictionary:tOldSubscriptionProducts];
	[tSubscriptionProducts setObject:aExpirationDate forKey:productKey];
	[tDefaults setObject:tSubscriptionProducts forKey:kSubscriptionProductsKey];
	[tDefaults synchronize];
	[tSubscriptionProducts release];
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

+(BOOL)subscriptionActive:(NSString*)productKey
{
	NSDictionary* tSubscriptionProducts = [[NSUserDefaults standardUserDefaults] objectForKey:kSubscriptionProductsKey];
	NSDate* tExpirationDate = [tSubscriptionProducts objectForKey:productKey];
	if( tExpirationDate ) {
		NSDate* tNow = [NSDate date];
		if( [tNow compare:tExpirationDate]==NSOrderedAscending ) {
			return YES;
		}
	}
	return NO;
}

@end
