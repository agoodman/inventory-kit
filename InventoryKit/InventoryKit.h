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
#import "IKSubscriptionDelegate.h"

#define kTransitionProductsKey @"TransitionKitProductsKey"
#define kActivatedProductsKey @"ActivatedProductsKey"
#define kConsumableProductsKey @"ConsumableProductsKey"
#define kSubscriptionProductsKey @"SubscriptionProductsKey"


@interface InventoryKit : NSObject {}

#pragma mark Shared

+(void)registerWithPaymentQueue;
+(void)purchaseProduct:(NSString*)productKey delegate:(id<IKPurchaseDelegate>)delegate;
+(BOOL)productActivated:(NSString*)productKey;
+(BOOL)isSubscriptionProduct:(NSString*)productKey;
+(BOOL)isConsumableProduct:(NSString*)productKey;

// reserved for future use
+(void)setApiToken:(NSString*)aApiToken;

// reserved for future use
+(void)useSandbox:(BOOL)sandbox;


#pragma mark TransitionKit

+(void)prepareTransitionProducts;

#pragma mark Non-Consumables

+(void)activateProduct:(NSString*)productKey;
+(void)deactivateProduct:(NSString*)productKey;
+(void)restoreProducts:(id<IKRestoreDelegate>)delegate;

#pragma mark Consumables

+(void)activateProduct:(NSString*)productKey quantity:(int)aQuantity;
+(int)quantityAvailableForProduct:(NSString*)productKey;
+(BOOL)canConsumeProduct:(NSString*)productKey quantity:(int)aQuantity;
+(void)consumeProduct:(NSString*)productKey quantity:(int)aQuantity;

#pragma mark Subscriptions

+(void)activateProduct:(NSString*)productKey expirationDate:(NSDate*)aExpirationDate;

@end
