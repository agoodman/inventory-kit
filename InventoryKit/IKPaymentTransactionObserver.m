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
-(void)fireProductPurchaseStarted:(NSString*)productIdentifier;
-(void)fireProductPurchaseFailed:(NSString*)productIdentifier;
-(void)fireProductPurchaseCompleted:(NSString*)productIdentifier;
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
				NSLog(@"transaction purchased: %@",t.transactionIdentifier);
			case SKPaymentTransactionStateRestored:
				NSLog(@"transaction restored: %@",t.transactionIdentifier);
				[self activateProductOrSubscription:t.payment.productIdentifier purchaseDate:t.transactionDate quantity:t.payment.quantity];
				[[SKPaymentQueue defaultQueue] finishTransaction:t];
				[self fireProductPurchaseCompleted:t.payment.productIdentifier];
				break;
			case SKPaymentTransactionStateFailed:
				NSLog(@"transaction failed: %@",t.transactionIdentifier);
				[self fireProductPurchaseFailed:t.payment.productIdentifier];
				break;
			case SKPaymentTransactionStatePurchasing:
				NSLog(@"transaction purchasing: %@",t.transactionIdentifier);	
				[self fireProductPurchaseStarted:t.payment.productIdentifier];
				break;
			default:
				break;
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

- (void)fireProductPurchaseCompleted:(NSString*)productKey
{
	NSArray* tKeys = [[delegates keyEnumerator] allObjects];
	if( [tKeys containsObject:productKey] ) {
		id<IKPurchaseDelegate> tDelegate = [delegates objectForKey:productKey];
		[tDelegate purchaseDidCompleteForProductWithKey:productKey];
		[delegates removeObjectForKey:productKey];
	}
}

- (void)fireProductPurchaseFailed:(NSString*)productKey
{
	NSArray* tKeys = [[delegates keyEnumerator] allObjects];
	if( [tKeys containsObject:productKey] ) {
		id<IKPurchaseDelegate> tDelegate = [delegates objectForKey:productKey];
		[tDelegate purchaseDidFailForProductWithKey:productKey];
		[delegates removeObjectForKey:productKey];
	}
}

- (void)fireProductPurchaseStarted:(NSString*)productKey
{
	NSArray* tKeys = [[delegates keyEnumerator] allObjects];
	if( [tKeys containsObject:productKey] ) {
		id<IKPurchaseDelegate> tDelegate = [delegates objectForKey:productKey];
		[tDelegate purchaseDidStartForProductWithKey:productKey];
	}
}

- (void)activateProductOrSubscription:(NSString*)productIdentifier purchaseDate:(NSDate*)purchaseDate quantity:(int)quantity
{
	if( [InventoryKit isSubscriptionProduct:productIdentifier] ) {
		// determine expiration date
		NSDictionary* tSubscriptionProducts = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"IKSubscriptionProducts" ofType:@"plist"]];
		NSTimeInterval tInterval = [[tSubscriptionProducts objectForKey:productIdentifier] intValue];
		NSDate* tExpirationDate = [purchaseDate dateByAddingTimeInterval:tInterval*quantity];
		
		[InventoryKit activateProduct:productIdentifier expirationDate:tExpirationDate];
	}else if( [InventoryKit isConsumableProduct:productIdentifier] ) {
		// read quantity data from the consumables plist
		NSDictionary* tConsumableProducts = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"IKConsumableProducts" ofType:@"plist"]];
		int tQuantityPerProduct = [[tConsumableProducts objectForKey:productIdentifier] intValue];
		int tQuantity = tQuantityPerProduct * quantity;
		[InventoryKit activateProduct:productIdentifier quantity:tQuantity];
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
