//
//  IKCustomer.h
//  IKExample
//
//  Created by Aubrey Goodman on 3/7/11.
//  Copyright 2011 Migrant Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectiveResource.h"


@interface IKCustomer : NSObject {

	NSNumber* customerId;
	NSString* email;
	
}

@property (retain) NSNumber* customerId;
@property (retain) NSString* email;

@end
