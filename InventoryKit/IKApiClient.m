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
#import "ProductRequest.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSString+SHA1.h"
#import "ReceiptRequest.h"
#import "CustomerRequest.h"


static int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface IKApiClient (private)
+(IKProductObserver*)productObserver;
+(dispatch_queue_t)syncQueue;
+(void)pullProductsFromAppStore;
+(void)pullProducts;
+(void)pullCustomer;
+(void)createCustomer;
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
	for (IKProduct* product in aProducts) {
		IKProductBlock tSuccess = ^(IKProduct* aProduct) {
			DDLogVerbose(@"Product %@ updated successfully",aProduct.identifier);
		};
		
		IKErrorBlock tFailure = ^(int aStatusCode, NSString* aResponse) {
			DDLogVerbose(@"Failed to update %@, error: %@",product.identifier,aResponse);
		};
		
		[ProductRequest requestUpdateProduct:product successBlock:tSuccess failureBlock:tFailure];
	}
}

+ (void)processReceipt:(NSData*)aReceipt
{
	IKBasicBlock tSuccess = ^{
		DDLogVerbose(@"receipt successfully processed");
	};
	
	IKErrorBlock tFailure = ^(int aStatusCode, NSString* aResponse) {
		DDLogVerbose(@"unable to process receipt");
	};
	
	[ReceiptRequest requestCreateReceipt:aReceipt successBlock:tSuccess failureBlock:tFailure];
}

#pragma mark private

+ (void)pullProducts
{
	dispatch_async([self syncQueue], ^{
		IKArrayBlock tSuccess = ^(NSArray* aProducts) {
			NSString* tPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"IKSubscriptionPrices.plist"];
			NSDictionary* tOldSubscriptionPrices = [NSDictionary dictionaryWithContentsOfFile:tPath];
			NSMutableDictionary* tSubscriptionPrices = [[NSMutableDictionary alloc] initWithDictionary:tOldSubscriptionPrices];
			NSMutableSet* tDeltas = [[NSMutableSet alloc] init];
			
			for (IKProduct* product in aProducts) {
				NSNumber* tPrice = [tSubscriptionPrices objectForKey:product.identifier];
				if( tPrice==nil ) continue;
				if( fabs([product.price floatValue]-[tPrice floatValue])>0.01 ) {
					[tDeltas addObject:product.identifier];
					[tSubscriptionPrices setObject:product.price forKey:product.identifier];
				}
			}
			
			if( tDeltas.count>0 ) {
				DDLogVerbose(@"saving products locally: %@",tSubscriptionPrices);
				[tSubscriptionPrices writeToFile:tPath atomically:YES];
			}
			
			[tSubscriptionPrices release];
			[tDeltas release];
		};
		
		IKErrorBlock tFailure = ^(int aStatusCode, NSString* aResponse) {
			// do nothing on failure; this is a background process
			DDLogVerbose(@"unable to retrieve products");
		};
		
		[ProductRequest requestProductsWithSuccessBlock:tSuccess failureBlock:tFailure];
		
	});
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
		
		IKCustomerBlock tSuccess = ^(IKCustomer* aCustomer) {
			DDLogVerbose(@"Received customer: %@",aCustomer);
			for (IKSubscription* tSubscription in aCustomer.subscriptions) {
				[InventoryKit activateProduct:tSubscription.productIdentifier expirationDate:tSubscription.expiresOn];
			}
		};
		
		IKErrorBlock tFailure = ^(int aStatusCode, NSString* aResponse) {
			DDLogVerbose(@"Customer does not exist.");
			[self createCustomer];
		};
		
		[CustomerRequest requestCustomerByEmail:tCustomerEmail success:tSuccess failure:tFailure];
	});
}

+ (void)createCustomer
{
	// generate secret key
	NSString* tCustomerEmail = [InventoryKit customerEmail];

	IKCustomerBlock tSuccess = ^(IKCustomer* aCustomer) {
		// do nothing
		DDLogVerbose(@"Created customer %@",aCustomer.email);
	};
	
	IKErrorBlock tFailure = ^(int aStatusCode, NSString* aResponse) {
		// do nothing
		DDLogVerbose(@"Failed to create customer %@",tCustomerEmail);
	};
	
	[CustomerRequest requestCreateCustomerByEmail:tCustomerEmail success:tSuccess failure:tFailure];
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
		NSString* tSecretKey = [[NSString stringWithFormat:@"--%@--%@--",productKey,tCustomerEmail] secretKey];
		
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
