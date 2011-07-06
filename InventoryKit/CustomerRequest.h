//
//  CustomerRequest.h
//  Uptimetry
//
//  Created by Aubrey Goodman on 7/5/11.
//  Copyright 2011 Migrant Studios LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InventoryKit.h"
#import "IKCustomer.h"


@interface CustomerRequest : NSObject {

}

+(void)requestCustomerByEmail:(NSString*)aEmail success:(IKCustomerBlock)aSuccess failure:(IKErrorBlock)aFailure;
+(void)requestCreateCustomerByEmail:(NSString*)aEmail success:(IKCustomerBlock)aSuccess failure:(IKErrorBlock)aFailure;

@end
