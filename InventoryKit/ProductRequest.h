//
//  ProductRequest.h
//  InventoryKit
//
//  Created by Aubrey Goodman on 3/20/11.
//  Copyright 2011 Migrant Studios LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IKProduct.h"


typedef void (^ProductIndexSuccessBlock)(NSArray* products);
typedef void (^ProductUpdateSuccessBlock)(IKProduct* product);
typedef void (^ProductFailureBlock)(void);


@interface ProductRequest : NSObject {

}

+(void)requestProductsWithSuccessBlock:(ProductIndexSuccessBlock)successBlock failureBlock:(ProductFailureBlock)failureBlock;
+(void)requestUpdateProduct:(IKProduct*)aProduct successBlock:(ProductUpdateSuccessBlock)successBlock failureBlock:(ProductFailureBlock)failureBlock;

@end
