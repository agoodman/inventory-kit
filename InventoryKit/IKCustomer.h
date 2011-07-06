//
//  IKCustomer.h
//  IKExample
//
//  Created by Aubrey Goodman on 3/7/11.
//  Copyright 2011 Migrant Studios. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IKCustomer : NSObject {

	NSNumber* customerId;
	NSString* email;
	NSArray* subscriptions;
	
}

@property (retain) NSNumber* customerId;
@property (retain) NSString* email;
@property (retain) NSArray* subscriptions;

+(id)customerWithDictionary:(NSDictionary*)aDictionary;

@end


typedef void (^IKCustomerBlock)(IKCustomer*);
