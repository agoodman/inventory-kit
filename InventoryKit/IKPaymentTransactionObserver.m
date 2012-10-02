//
//  IKPaymentTransactionObserver.m
//  InventoryKit
//
//  Created by Aubrey Goodman on 11/12/09.
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

#import "IKPaymentTransactionObserver.h"
#import "InventoryKit.h"
#import "IKApi.h"


static int ddLogLevel = LOG_LEVEL_WARN;

@interface IKPaymentTransactionObserver (private)
-(void)fireProductPurchaseStarted:(NSString*)productIdentifier;
-(void)fireProductPurchaseFailed:(NSString*)productIdentifier error:(NSError*)error;
-(void)fireProductPurchaseCompleted:(NSString*)productIdentifier;
-(void)activateProductOrSubscription:(NSString*)productIdentifier purchaseDate:(NSDate*)purchaseDate quantity:(int)quantity;
-(void)addObserverForProductIdentifier:(NSString*)productIdentifier successBlock:(IKStringBlock)aSuccessBlock failureBlock:(IKErrorBlock)aFailureBlock;
@end


@implementation IKPaymentTransactionObserver

@synthesize restoreSuccessBlock, restoreFailureBlock, productBlock;

- (id)init
{
	delegates = [[NSMutableDictionary alloc] init];
	startBlocks = [[NSMutableDictionary alloc] init];
	successBlocks = [[NSMutableDictionary alloc] init];
	failureBlocks = [[NSMutableDictionary alloc] init];
	return self;
}

- (bool)isTransactionPendingForProduct:(NSString*)productIdentifier
{
	return [[delegates allKeys] containsObject:productIdentifier] ||
		[[successBlocks allKeys] containsObject:productIdentifier] ||
		[[failureBlocks allKeys] containsObject:productIdentifier];
}

- (void)addPurchaseDelegate:(id<IKPurchaseDelegate>)delegate productIdentifier:(NSString*)productIdentifier
{
	[delegates setObject:delegate forKey:productIdentifier];
}

- (void)setRestoreDelegate:(id<IKRestoreDelegate>)delegate
{
	restoreDelegate = delegate;
}

- (void)addObserverForProductIdentifier:(NSString *)productIdentifier startBlock:(IKBasicBlock)aStartBlock successBlock:(IKStringBlock)aSuccessBlock failureBlock:(IKErrorBlock)aFailureBlock
{
	[startBlocks setObject:[aStartBlock copy] forKey:productIdentifier];
	[successBlocks setObject:[aSuccessBlock copy] forKey:productIdentifier];
	[failureBlocks setObject:[aFailureBlock copy] forKey:productIdentifier];
}

- (void)removeObserversForProductIdentifier:(NSString *)productIdentifier
{
	[startBlocks removeObjectForKey:productIdentifier];
	[successBlocks removeObjectForKey:productIdentifier];
	[failureBlocks removeObjectForKey:productIdentifier];
}

- (void)paymentQueue:(SKPaymentQueue*)queue updatedTransactions:(NSArray*)transactions
{
	for (SKPaymentTransaction* t in transactions) {
		switch (t.transactionState) {
			case SKPaymentTransactionStatePurchased:
				DDLogVerbose(@"transaction purchased: %@",t.transactionIdentifier);
			case SKPaymentTransactionStateRestored:
				DDLogVerbose(@"transaction restored: %@",t.transactionIdentifier);
				[self activateProductOrSubscription:t.payment.productIdentifier purchaseDate:t.transactionDate quantity:t.payment.quantity];
				[InventoryKit processReceipt:t.transactionReceipt];
				[[SKPaymentQueue defaultQueue] finishTransaction:t];
				[self fireProductPurchaseCompleted:t.payment.productIdentifier];
				break;
			case SKPaymentTransactionStateFailed:
				DDLogVerbose(@"transaction failed: %@",t.transactionIdentifier);
				[[SKPaymentQueue defaultQueue] finishTransaction:t];
				[self fireProductPurchaseFailed:t.payment.productIdentifier error:t.error];
				break;
			case SKPaymentTransactionStatePurchasing:
				DDLogVerbose(@"transaction purchasing: %@",t.transactionIdentifier);	
				[self fireProductPurchaseStarted:t.payment.productIdentifier];
				break;
			default:
				break;
		}
	}
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
	if( restoreDelegate ) {
		[restoreDelegate productRestoreFailed:error];
	}else if( restoreFailureBlock ) {
		restoreFailureBlock([error code],[error localizedDescription]);
	}
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
	if( restoreDelegate ) {
		[restoreDelegate productsRestored];
	}else if( restoreSuccessBlock ) {
		restoreSuccessBlock();
	}
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    if( productBlock ) {
        productBlock(response.products);
    }
}

#pragma mark private

- (void)fireProductPurchaseCompleted:(NSString*)productKey
{
	id<IKPurchaseDelegate> tDelegate = [delegates objectForKey:productKey];
	if( tDelegate ) {
		[tDelegate purchaseDidCompleteForProductWithKey:productKey];
		[delegates removeObjectForKey:productKey];
	}else{
		IKStringBlock tBlock = [successBlocks objectForKey:productKey];
		if( tBlock ) {
			tBlock(productKey);
			[self removeObserversForProductIdentifier:productKey];
		}
	}
}

- (void)fireProductPurchaseFailed:(NSString*)productKey error:(NSError*)error;
{
	id<IKPurchaseDelegate> tDelegate = [delegates objectForKey:productKey];
	if( tDelegate ) {
		[tDelegate purchaseDidFailForProductWithKey:productKey];
		[delegates removeObjectForKey:productKey];
	}else{
		IKErrorBlock tBlock = [failureBlocks objectForKey:productKey];
		if( tBlock ) {
			tBlock([error code],[error localizedDescription]);
			[self removeObserversForProductIdentifier:productKey];
		}
	}
}

- (void)fireProductPurchaseStarted:(NSString*)productKey
{
	id<IKPurchaseDelegate> tDelegate = [delegates objectForKey:productKey];
	if( tDelegate ) {
		[tDelegate purchaseDidStartForProductWithKey:productKey];
	}else{
		IKBasicBlock tBlock = [startBlocks objectForKey:productKey];
		if( tBlock ) {
			tBlock();
		}
	}
}

- (void)activateProductOrSubscription:(NSString*)productIdentifier purchaseDate:(NSDate*)purchaseDate quantity:(int)quantity
{
	if( [InventoryKit isSubscriptionProduct:productIdentifier] ) {
		// determine expiration date
		NSDictionary* tSubscriptionProducts = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"IKSubscriptionProducts" ofType:@"plist"]];
		NSDictionary* tSubscription = [tSubscriptionProducts objectForKey:productIdentifier];
		NSTimeInterval tInterval = [[tSubscription objectForKey:@"duration"] intValue];
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

@end
