//
//  IKPaymentTransactionObserver.h
//  InventoryKit
//
//  Created by Aubrey Goodman on 11/12/09.
//  Copyright 2009 Migrant Studios LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "IKPurchaseDelegate.h"
#import "IKRestoreDelegate.h"


@interface IKPaymentTransactionObserver : NSObject <SKPaymentTransactionObserver> {

	NSMutableDictionary* delegates;
	id<IKRestoreDelegate> restoreDelegate;
	
}

-(bool)isTransactionPendingForProduct:(NSString*)productIdentifier;
-(void)addPurchaseDelegate:(id<IKPurchaseDelegate>)delegate productIdentifier:(NSString*)productIdentifier;
-(void)setRestoreDelegate:(id<IKRestoreDelegate>)delegate;

	
@end
