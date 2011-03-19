//
//  IKApiClient.h
//  IKExample
//
//  Created by Aubrey Goodman on 3/7/11.
//  Copyright 2011 Migrant Studios. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IKApiClient : NSObject {

}

+(void)syncProducts;
+(void)syncCustomer;
+(void)syncSubscriptions;
+(void)updateProducts:(NSSet*)products;

@end
