//
//  ProductRequest.h
//  InventoryKit
//
//  Created by Aubrey Goodman on 3/20/11.
//  Copyright 2011 Migrant Studios LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InventoryKit.h"
#import "IKProduct.h"



@interface ProductRequest : NSObject {

}

+(void)requestProductsWithSuccessBlock:(IKArrayBlock)successBlock failureBlock:(IKErrorBlock)failureBlock;
+(void)requestUpdateProduct:(IKProduct*)aProduct successBlock:(IKProductBlock)successBlock failureBlock:(IKErrorBlock)failureBlock;

@end
