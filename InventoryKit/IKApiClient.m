//
//  IKApiClient.m
//  IKExample
//
//  Created by Aubrey Goodman on 3/7/11.
//  Copyright 2011 Migrant Studios. All rights reserved.
//

#import "IKApiClient.h"
#import "IKProduct.h"
#import "IKProductObserver.h"
#import "IKSubscription.h"
#import "IKCustomer.h"
#import "InventoryKit.h"
#import <CommonCrypto/CommonDigest.h>


@interface IKApiClient (private)
+(IKProductObserver*)productObserver;
+(dispatch_queue_t)syncQueue;
+(void)pullProductsFromAppStore;
+(void)pullProducts;
+(void)pullCustomer;
@end


@implementation IKApiClient

+ (void)syncProducts
{
	[self pullProducts];
	[self pullProductsFromAppStore];
}

+ (void)syncCustomer
{
	[self pullCustomer];
}

+ (void)updateProducts:(NSSet*)aProducts
{
	dispatch_async(dispatch_get_main_queue(), ^{ NSLog(@"TODO",@"push updated product data to server"); });
}

#pragma mark private

+ (void)pullProducts
{
//	dispatch_async([self syncQueue], ^{
		NSDictionary* tOldSubscriptionPrices = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"IKSubscriptionPrices" ofType:@"plist"]];
		NSMutableDictionary* tSubscriptionPrices = [[NSMutableDictionary alloc] initWithDictionary:tOldSubscriptionPrices];
		NSMutableSet* tDeltas = [[NSMutableSet alloc] init];
		
		NSArray* tProducts = [IKProduct findAllRemote];
		for (IKProduct* product in tProducts) {
			NSNumber* tPrice = [tSubscriptionPrices objectForKey:product.identifier];
			if( fabs([product.price floatValue]-[tPrice floatValue])>0.01 ) {
				[tDeltas addObject:product.identifier];
				[tSubscriptionPrices setObject:product.price forKey:product.identifier];
			}
		}
		
		if( tDeltas.count>0 ) {
			[tSubscriptionPrices writeToFile:[[NSBundle mainBundle] pathForResource:@"IKSubscriptionPrices" ofType:@"plist"] atomically:YES];
		}
		
		[tSubscriptionPrices release];
		[tDeltas release];
//	});
}

+ (void)pullProductsFromAppStore
{
	dispatch_async([self syncQueue], ^{
		// attempt to query products from iTunes
		if( [SKPaymentQueue canMakePayments] ) {
			NSDictionary* tSubscriptionProducts = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"IKSubscriptionProducts" ofType:@"plist"]];
			NSSet* tProductIds = [NSSet setWithArray:[tSubscriptionProducts allKeys]];
			SKProductsRequest* tRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:tProductIds];
			tRequest.delegate = [self productObserver];
			[tRequest start];
		}
	});
}

+ (void)pullCustomer
{
	dispatch_async([self syncQueue], ^{
		// generate secret key
		NSString* tCustomerEmail = [InventoryKit customerEmail];
		NSString* tSecretKey = [[NSString stringWithFormat:@"--%@--",tCustomerEmail] hexdigest];
		
		IKCustomer* tCustomer = [IKCustomer findRemote:tSecretKey];
		NSLog(@"TODO: extract subscription data from customer");
	});
}

/*
 * web service supports a SHA1 hex digest public key generated from the following pattern:
 * --<ProductId>--<CustomerEmail>--
 */
+ (void)updateSubscription:(NSString*)productKey expirationDate:(NSDate*)aExpirationDate
{
	dispatch_async([self syncQueue], ^{
		// generate secret key
		NSString* tCustomerEmail = [InventoryKit customerEmail];
		NSString* tSecretKey = [[NSString stringWithFormat:@"--%@--%@--",productKey,tCustomerEmail] hexdigest];
		
		IKSubscription* tSubscription = [[[IKSubscription alloc] init] autorelease];

//		// retrieve current subscriptions
//		NSArray* tSubscriptions = [[NSUserDefaults standardUserDefaults] objectForKey:kSubscriptionsKey];
//		NSDictionary* tSubscriptionDict = nil;
//		for (NSDictionary* dict in tSubscriptions) {
//			if( [[dict objectForKey:@"productId"] intValue]==[tProduct.productId intValue] ) {
//				IKSubscription* tSubscription = [[[IKSubscription alloc] init] autorelease];
//				tSubscription.subscriptionId = nil;
//			}
//		}
//		for (IKSubscription* subscription in tSubscriptions) {
//			if( [subscription.customerId intValue]==[[NSUserDefaults standardUserDefaults] integerForKey:@"CustomerId"] &&
//			   [subscription.productId ) 
//			{
//				tSubscription = subscription;
//			}
//		}
	});
}
				 
+ (IKProductObserver*)productObserver
{
	static IKProductObserver* sProductObserver;
	if( sProductObserver==nil ) {
		sProductObserver = [[IKProductObserver alloc] init];
	}
	return sProductObserver;
}

+ (dispatch_queue_t)syncQueue
{
	static dispatch_queue_t sSyncQueue;
	if( sSyncQueue==nil ) {
		sSyncQueue = dispatch_queue_create("ik.sync", 0);
	}
	return sSyncQueue;
}

@end
