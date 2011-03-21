/*
 *  IKPurchaseDelegate.h
 *  InventoryKit
 *
 *  Created by Aubrey Goodman on 11/12/09.
 *  Copyright 2009 Migrant Studios LLC. All rights reserved.
 *
 */

@protocol IKPurchaseDelegate
-(void)purchaseDidStartForProductWithKey:(NSString*)productKey;
-(void)purchaseDidFailForProductWithKey:(NSString*)productKey;
-(void)purchaseDidCompleteForProductWithKey:(NSString*)productKey;
@end

