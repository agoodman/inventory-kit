//
//  IKProduct.m
//  IKExample
//
//  Created by Aubrey Goodman on 3/7/11.
//  Copyright 2011 Migrant Studios. All rights reserved.
//

#import "IKProduct.h"


@implementation IKProduct

@synthesize productId, identifier, price, duration, createdAt, updatedAt;

+ (NSString*)getRemoteCollectionName
{
	return @"products";
}

- (void)dealloc
{
	[productId release];
	[identifier release];
	[price release];
	[createdAt release];
	[updatedAt release];
	[super dealloc];
}

@end
