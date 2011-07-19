//
//  InventoryKit.h
//  InventoryKit
//
//  Created by Aubrey Goodman on 10/25/09.
//  Copyright 2009 Migrant Studios LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IKPurchaseDelegate.h"
#import "IKRestoreDelegate.h"
#import "IKProduct.h"

#define kTransitionProductsKey @"TransitionKitProductsKey"
#define kActivatedProductsKey @"ActivatedProductsKey"
#define kConsumableProductsKey @"ConsumableProductsKey"
#define kSubscriptionProductsKey @"SubscriptionProductsKey"
#define kProductsKey @"ProductsKey"
#define kSubscriptionsKey @"SubscriptionsKey"


typedef void (^IKBasicBlock)(void);
typedef void (^IKArrayBlock)(NSArray*);
typedef void (^IKStringBlock)(NSString*);
typedef void (^IKErrorBlock)(int,NSString*);

@interface InventoryKit : NSObject {}

#pragma mark Shared

+(void)registerWithPaymentQueue;
+(BOOL)productActivated:(NSString*)productKey;
+(BOOL)isSubscriptionProduct:(NSString*)productKey;
+(BOOL)isConsumableProduct:(NSString*)productKey;
+(IKProduct*)productWithIdentifier:(NSString*)productKey;

#pragma mark TransitionKit

+(void)prepareTransitionProducts;

#pragma mark EnrollMint

+(void)useSandbox:(BOOL)sandbox;
+(NSString*)serverUrl;
+(void)setApiToken:(NSString*)aApiToken;
+(NSString*)apiToken;
+(void)setCustomerEmail:(NSString*)aEmail;
+(NSString*)customerEmail;

#pragma mark Purchasing delegate-based

+(void)purchaseProduct:(NSString*)productKey delegate:(id<IKPurchaseDelegate>)delegate;
+(void)purchaseProduct:(NSString*)productKey quantity:(int)quantity delegate:(id<IKPurchaseDelegate>)delegate;
+(void)restoreProducts:(id<IKRestoreDelegate>)delegate;

#pragma mark Purchasing block-based

+(void)purchaseProduct:(NSString *)productKey startBlock:(IKBasicBlock)aStartBlock successBlock:(IKStringBlock)successBlock failureBlock:(IKErrorBlock)failureBlock;
+(void)purchaseProduct:(NSString *)productKey quantity:(int)quantity startBlock:(IKBasicBlock)aStartBlock successBlock:(IKStringBlock)successBlock failureBlock:(IKErrorBlock)failureBlock;
+(void)restoreProductsWithSuccessBlock:(IKBasicBlock)successBlock failureBlock:(IKErrorBlock)failureBlock;

#pragma mark Non-Consumables

+(void)activateProduct:(NSString*)productKey;
+(void)deactivateProduct:(NSString*)productKey;

#pragma mark Consumables

+(void)activateProduct:(NSString*)productKey quantity:(int)aQuantity;
+(int)quantityAvailableForProduct:(NSString*)productKey;
+(BOOL)canConsumeProduct:(NSString*)productKey quantity:(int)aQuantity;
+(void)consumeProduct:(NSString*)productKey quantity:(int)aQuantity;

#pragma mark Subscriptions

+(void)activateProduct:(NSString*)productKey expirationDate:(NSDate*)aExpirationDate;

@end
