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

#define kTransitionProductsKey @"TransitionKitProductsKey"
#define kActivatedProductsKey @"ActivatedProductsKey"


@interface InventoryKit : NSObject {}

+(void)registerWithPaymentQueue;
+(void)prepareTransitionProducts;
+(bool)productActivated:(NSString*)productKey;
+(void)activateProduct:(NSString*)productKey;
+(void)deactivateProduct:(NSString*)productKey;
+(void)purchaseProduct:(NSString*)productKey delegate:(id<IKPurchaseDelegate>)delegate;
+(void)restoreProducts:(id<IKRestoreDelegate>)delegate;

@end
