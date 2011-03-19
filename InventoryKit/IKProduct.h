//
//  IKProduct.h
//  IKExample
//
//  Created by Aubrey Goodman on 3/7/11.
//  Copyright 2011 Migrant Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectiveResource.h"


@interface IKProduct : NSObject {

	NSNumber* productId;
	NSString* identifier;
	NSNumber* price;
	NSNumber* duration;
	NSDate* createdAt;
	NSDate* updatedAt;
}

@property (retain) NSNumber* productId;
@property (retain) NSString* identifier;
@property (retain) NSNumber* price;
@property (retain) NSNumber* duration;
@property (retain) NSDate* createdAt;
@property (retain) NSDate* updatedAt;

@end
