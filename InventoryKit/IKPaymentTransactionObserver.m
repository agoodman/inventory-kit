//
//  IKPaymentTransactionObserver.m
//  InventoryKit
//
//  Created by Aubrey Goodman on 11/12/09.
//  Copyright 2009 Migrant Studios LLC. All rights reserved.
//

#import "IKPaymentTransactionObserver.h"
#import "InventoryKit.h"


@interface IKPaymentTransactionObserver (private)

-(void)fireProductPurchased:(NSString*)productIdentifier success:(bool)success;

@end


@implementation IKPaymentTransactionObserver

- (id)init
{
	delegates = [[NSMutableDictionary alloc] init];
	return self;
}

- (void)addPurchaseDelegate:(id<IKPurchaseDelegate>)delegate productIdentifier:(NSString*)productIdentifier
{
	[delegates setObject:delegate forKey:productIdentifier];
}

- (void)setRestoreDelegate:(id<IKRestoreDelegate>)delegate
{
	restoreDelegate = delegate;
}

- (bool)isTransactionPendingForProduct:(NSString*)productIdentifier
{
	return [[[delegates keyEnumerator] allObjects] containsObject:productIdentifier];
}

- (void)paymentQueue:(SKPaymentQueue*)queue updatedTransactions:(NSArray*)transactions
{
	for (SKPaymentTransaction* t in transactions) {
		switch (t.transactionState) {
			case SKPaymentTransactionStatePurchased:
			case SKPaymentTransactionStateRestored:
				[InventoryKit activateProduct:t.payment.productIdentifier];
				[self fireProductPurchased:t.payment.productIdentifier success:true];
				[[SKPaymentQueue defaultQueue] finishTransaction:t];
				break;
			case SKPaymentTransactionStateFailed:
				[self fireProductPurchased:t.payment.productIdentifier success:false];
				[[SKPaymentQueue defaultQueue] finishTransaction:t];
				break;
			default:
				break;
		}
		
		if( t.transactionState==SKPaymentTransactionStatePurchased || t.transactionState==SKPaymentTransactionStateRestored ) {
			NSLog(@"Received transaction for %@",t.payment.productIdentifier);
		}
	}
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
	[restoreDelegate productRestoreFailed:error];
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
	[restoreDelegate productsRestored];
}

#pragma mark private

- (void)fireProductPurchased:(NSString*)productKey success:(bool)success
{
	NSArray* tKeys = [[delegates keyEnumerator] allObjects];
	if( [tKeys containsObject:productKey] ) {
		id<IKPurchaseDelegate> tDelegate = [delegates objectForKey:productKey];
		[tDelegate productWithKey:productKey success:success];
		[delegates removeObjectForKey:productKey];
	}
}

#pragma mark 

- (void)dealloc
{
	[delegates release];
	[super dealloc];
}


@end
