//
//  IKSubscription.h
//  IKExample
//
//  Created by Aubrey Goodman on 3/7/11.
//  Copyright 2011 Migrant Studios. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IKSubscription : NSObject {

	NSNumber* subscriptionId;
	NSNumber* customerId;
	NSNumber* productId;
	NSDate* expiresOn;
	
}

@property (retain) NSNumber* subscriptionId;
@property (retain) NSNumber* customerId;
@property (retain) NSNumber* productId;
@property (retain) NSDate* expiresOn;

@end
