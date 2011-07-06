//
//  ReceiptRequest.h
//  InventoryKit
//
//  Created by Aubrey Goodman on 7/3/11.
//  Copyright 2011 Migrant Studios LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InventoryKit.h"


@interface ReceiptRequest : NSObject {

}

+(void)requestCreateReceipt:(NSData*)aReceipt successBlock:(IKBasicBlock)aSuccessBlock failureBlock:(IKErrorBlock)aFailureBlock;

@end
