//
//  IKApi.h
//  InventoryKit
//
//  Created by Aubrey Goodman on 2/18/12.
//  Copyright (c) 2012 Migrant Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IKCustomer.h"


@protocol IKApi <NSObject>
-(void)findOrCreateCustomerByEmail:(NSString*)aEmail successBlock:(IKCustomerBlock)successBlock failureBlock:(dispatch_block_t)failureBlock;
@end
