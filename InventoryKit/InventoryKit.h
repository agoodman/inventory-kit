//
//  InventoryKit.h
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

#import <Foundation/Foundation.h>
#import "IKPurchaseDelegate.h"
#import "IKRestoreDelegate.h"
#import "IKProduct.h"
#import "IKApi.h"

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

+(void)setApiClient:(id<IKApi>)aClient;
+(void)updateProducts:(NSArray*)aProducts;
+(void)useSandbox:(BOOL)sandbox;
+(NSString*)serverUrl;
+(void)setApiToken:(NSString*)aApiToken;
+(NSString*)apiToken;
+(void)setCustomerEmail:(NSString*)aEmail;
+(NSString*)customerEmail;

#pragma mark Retrieve Product block-based

+ (void)retrieveProductsWithIdentifiers:(NSSet*)aIdentifiers successBlock:(IKArrayBlock)aSuccessBlock;

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
+(void)processReceipt:(NSData*)aReceiptData;

@end
