//
//  IKPaymentTransactionObserver.h
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

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "InventoryKit.h"
#import "IKPurchaseDelegate.h"
#import "IKRestoreDelegate.h"


@interface IKPaymentTransactionObserver : NSObject <SKPaymentTransactionObserver,SKProductsRequestDelegate> {

	NSMutableDictionary* delegates;
	id<IKRestoreDelegate> restoreDelegate;

	NSMutableDictionary* startBlocks;
	NSMutableDictionary* successBlocks;
	NSMutableDictionary* failureBlocks;
	IKBasicBlock restoreSuccessBlock;
	IKErrorBlock restoreFailureBlock;
    IKArrayBlock productBlock;
	
}

@property (copy) IKBasicBlock restoreSuccessBlock;
@property (copy) IKErrorBlock restoreFailureBlock;
@property (copy) IKArrayBlock productBlock;

-(bool)isTransactionPendingForProduct:(NSString*)productIdentifier;

-(void)addPurchaseDelegate:(id<IKPurchaseDelegate>)delegate productIdentifier:(NSString*)productIdentifier;
-(void)setRestoreDelegate:(id<IKRestoreDelegate>)delegate;

-(void)addObserverForProductIdentifier:(NSString*)productIdentifier startBlock:(IKBasicBlock)aStartBlock successBlock:(IKStringBlock)aSuccessBlock failureBlock:(IKErrorBlock)aFailureBlock;
-(void)removeObserversForProductIdentifier:(NSString*)productIdentifier;

	
@end
