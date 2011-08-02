//
//  InventoryKit.m
//  InventoryKit
//
//  Created by Aubrey Goodman on 10/25/09.
//  Copyright 2009 Migrant Studios LLC. 
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//

#import "InventoryKit.h"
#import "IKPaymentTransactionObserver.h"
#import "IKApiClient.h"


static int ddLogLevel = LOG_LEVEL_WARN;

@interface InventoryKit (private)
static NSString* sApiToken;
static NSString* sServerUrl;
static NSString* sCustomerEmail;
static BOOL sUseSandbox;
+(IKPaymentTransactionObserver*)sharedObserver;
+(void)restoreTransitionProducts;
+(void)restoreProducts;
+(void)activateBundle:(NSString*)bundleKey;
+(BOOL)subscriptionActive:(NSString*)productKey;
+(void)queuePaymentForProductIdentifier:(NSString*)productKey quantity:(int)quantity;
@end


@implementation InventoryKit

#pragma mark Shared

+ (void)registerWithPaymentQueue
{
	[[SKPaymentQueue defaultQueue] addTransactionObserver:[InventoryKit sharedObserver]];
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
				DDLogVerbose(@"InventoryKit: Encountered unexpected object");
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

+ (IKProduct*)productWithIdentifier:(NSString*)productKey
{
	NSArray* tProducts = [[NSUserDefaults standardUserDefaults] objectForKey:kProductsKey];
	IKProduct* tProduct = nil;
	for (NSDictionary* dict in tProducts) {
		if( [productKey isEqualToString:[dict objectForKey:@"identifier"]] ) {
			tProduct = [[[IKProduct alloc] init] autorelease];
			tProduct.identifier = productKey;
			tProduct.productId = [dict objectForKey:@"productId"];
			break;
		}
	}
	return tProduct;
}

#pragma mark TransitionKit

+ (void)prepareTransitionProducts
{
	NSArray* tTransitionProducts = [[NSUserDefaults standardUserDefaults] objectForKey:kTransitionProductsKey];
	if( tTransitionProducts==nil ) {
		NSString* pathToProductKeys = [[NSBundle mainBundle] pathForResource:@"TransitionProducts" ofType:@"plist"];
		tTransitionProducts = [NSArray arrayWithContentsOfFile:pathToProductKeys];
		if( tTransitionProducts==nil ) {
			DDLogWarn(@"Unable to resolve products from file: TransitionProducts.plist");
		}else{
			[[NSUserDefaults standardUserDefaults] setObject:tTransitionProducts forKey:kTransitionProductsKey];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}
	}
}

#pragma mark EnrollMint

+ (void)useSandbox:(BOOL)sandbox
{
	sUseSandbox = sandbox;
}

+ (NSString*)serverUrl
{
	if( sUseSandbox ) {
		sServerUrl = @"https://sandbox.enrollmint.com/";
	}else{
		sServerUrl = @"https://api.enrollmint.com/";
	}
	NSString* tServerUrl = [NSString stringWithFormat:@"%@apps/%@/",sServerUrl,[[NSBundle mainBundle] bundleIdentifier]];
	return tServerUrl;
}

+ (void)setApiToken:(NSString*)aApiToken
{
	[sApiToken release];
	sApiToken = [aApiToken retain];
	
	//	[ObjectiveResourceConfig setSite:@"http://enrollmint.com/"];
	//	[ObjectiveResourceConfig setSite:@"http://local:3000/"];
	//	[ObjectiveResourceConfig setUser:sApiToken];
	//	[ObjectiveResourceConfig setPassword:@"x"];
	//	[ObjectiveResourceConfig setResponseType:JSONResponse];
	//	[ObjectiveResourceConfig setLocalClassesPrefix:@"IK"];
	
	[IKApiClient syncProducts];
}

+ (NSString*)apiToken
{
	return sApiToken;
}

+ (void)setCustomerEmail:(NSString *)aEmail
{
	[sCustomerEmail release];
	sCustomerEmail = [aEmail retain];
	
	if( sCustomerEmail ) {
		[IKApiClient syncCustomer];
	}
}

+ (NSString*)customerEmail
{
	return sCustomerEmail;
}

#pragma mark Purchasing delegate-based

+ (void)purchaseProduct:(NSString*)productKey delegate:(id<IKPurchaseDelegate>)delegate
{
	[self purchaseProduct:productKey quantity:1 delegate:delegate];
}

+ (void)purchaseProduct:(NSString*)productKey quantity:(int)quantity delegate:(id<IKPurchaseDelegate>)delegate
{
	[[InventoryKit sharedObserver] addPurchaseDelegate:delegate productIdentifier:productKey];
	
	[self queuePaymentForProductIdentifier:productKey quantity:quantity];
}

#pragma mark Purchasing block-based

+ (void)purchaseProduct:(NSString *)productKey startBlock:(IKBasicBlock)aStartBlock successBlock:(IKStringBlock)aSuccessBlock failureBlock:(IKErrorBlock)aFailureBlock
{
	[self purchaseProduct:productKey quantity:1 startBlock:aStartBlock successBlock:aSuccessBlock failureBlock:aFailureBlock];
}

+ (void)purchaseProduct:(NSString *)productKey quantity:(int)quantity startBlock:(IKBasicBlock)aStartBlock successBlock:(IKStringBlock)aSuccessBlock failureBlock:(IKErrorBlock)aFailureBlock
{
	[[InventoryKit sharedObserver] addObserverForProductIdentifier:productKey startBlock:aStartBlock successBlock:aSuccessBlock failureBlock:aFailureBlock];
	
	[self queuePaymentForProductIdentifier:productKey quantity:quantity];
}

#pragma mark Non-Consumables

+ (void)activateProduct:(NSString*)productKey
{
	DDLogVerbose(@"IK Activating %@",productKey);
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

+ (void)deactivateProduct:(NSString *)productKey
{
	DDLogVerbose(@"IK Dectivating %@",productKey);
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

+ (void)restoreProducts:(id<IKRestoreDelegate>)delegate
{
	if( [SKPaymentQueue canMakePayments] ) {
		DDLogVerbose(@"Requesting product restore");
		[[InventoryKit sharedObserver] setRestoreDelegate:delegate];
		
		[self restoreProducts];
	}else{
		UIAlertView* tAlert = [[[UIAlertView alloc] initWithTitle:@"Service Unavailable" 
							   message:@"Please try again later" 
							   delegate:nil
							   cancelButtonTitle:nil 
								otherButtonTitles:@"OK",nil] autorelease];
		[tAlert show];
	}
}

+ (void)restoreProductsWithSuccessBlock:(IKBasicBlock)successBlock failureBlock:(IKErrorBlock)failureBlock
{
	if( [SKPaymentQueue canMakePayments] ) {
		DDLogVerbose(@"Requesting product restore");
		[[InventoryKit sharedObserver] setRestoreSuccessBlock:successBlock];
		[[InventoryKit sharedObserver] setRestoreFailureBlock:failureBlock];
		
		[self restoreProducts];
	}else{
		failureBlock(0, @"Can not connect to iTunes");
	}
}

#pragma mark Consumables

+(void)activateProduct:(NSString*)productKey quantity:(int)aQuantity
{
	DDLogVerbose(@"IK Activating %dea of %@",productKey,aQuantity);
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
	DDLogVerbose(@"IK Consuming %dea of %@",aQuantity,productKey);
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
	DDLogVerbose(@"IK Activating %@ with expiration %@",productKey,aExpirationDate);
	NSUserDefaults* tDefaults = [NSUserDefaults standardUserDefaults];
	NSDictionary* tOldSubscriptionProducts = [tDefaults objectForKey:kSubscriptionProductsKey];
	NSMutableDictionary* tSubscriptionProducts = [[NSMutableDictionary alloc] initWithDictionary:tOldSubscriptionProducts];
	
	if( ! [[tSubscriptionProducts objectForKey:productKey] isEqual:aExpirationDate] ) {
		[tSubscriptionProducts setObject:aExpirationDate forKey:productKey];
	}
	
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
	DDLogVerbose(@"IK Restoring transition products");
	NSUserDefaults* tDefaults = [NSUserDefaults standardUserDefaults];
	NSArray* tActivatedProducts = [tDefaults objectForKey:kActivatedProductsKey];
	if( tActivatedProducts==nil ) {
		NSArray* tTransitionProducts = [tDefaults objectForKey:kTransitionProductsKey];
		[tDefaults setObject:[NSArray arrayWithArray:tTransitionProducts] forKey:kActivatedProductsKey];
		[tDefaults synchronize];
	}
}

+ (void)restoreProducts
{
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kActivatedProductsKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[InventoryKit restoreTransitionProducts];
	
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
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

+(void)queuePaymentForProductIdentifier:(NSString*)productKey quantity:(int)quantity
{
	SKMutablePayment* tPayment = [SKMutablePayment paymentWithProductIdentifier:productKey];
	tPayment.quantity = quantity;
	[[SKPaymentQueue defaultQueue] addPayment:tPayment];
}

@end
