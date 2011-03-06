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
-(void)fireProductPurchased:(NSString*)productIdentifier success:(BOOL)success;
-(void)activateProductOrSubscription:(NSString*)productIdentifier purchaseDate:(NSDate*)purchaseDate quantity:(int)quantity;
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
				[self activateProductOrSubscription:t.payment.productIdentifier purchaseDate:t.transactionDate quantity:t.payment.quantity];
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

- (void)fireProductPurchased:(NSString*)productKey success:(BOOL)success
{
	NSArray* tKeys = [[delegates keyEnumerator] allObjects];
	if( [tKeys containsObject:productKey] ) {
		id<IKPurchaseDelegate> tDelegate = [delegates objectForKey:productKey];
		[tDelegate productWithKey:productKey success:success];
		[delegates removeObjectForKey:productKey];
	}
}

- (void)activateProductOrSubscription:(NSString*)productIdentifier purchaseDate:(NSDate*)purchaseDate quantity:(int)quantity
{
	NSDictionary* tSubscriptionProducts = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"IKSubscriptionProducts" ofType:@"plist"]];
	if( [[tSubscriptionProducts allKeys] containsObject:productIdentifier] ) {
		// determine expiration date
		NSTimeInterval tInterval = [[tSubscriptionProducts objectForKey:productIdentifier] intValue];
		NSDate* tExpirationDate = [purchaseDate dateByAddingTimeInterval:tInterval*quantity];
		
		[InventoryKit activateProduct:productIdentifier expirationDate:tExpirationDate];
	}else if( [InventoryKit isConsumableProduct:productIdentifier] ) {
		[InventoryKit activateProduct:productIdentifier quantity:quantity];
	}else{
		[InventoryKit activateProduct:productIdentifier];
	}
}

#pragma mark 

- (void)dealloc
{
	[delegates release];
	[super dealloc];
}


@end
