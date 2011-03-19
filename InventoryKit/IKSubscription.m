//
//  IKSubscription.m
//  IKExample
//
//  Created by Aubrey Goodman on 3/7/11.
//  Copyright 2011 Migrant Studios. All rights reserved.
//

#import "IKSubscription.h"


@implementation IKSubscription

@synthesize subscriptionId, customerId, productId, expiresOn;

+ (NSString*)getRemoteCollectionName
{
	return @"subscriptions";
}

- (void)dealloc
{
	[subscriptionId release];
	[customerId release];
	[productId release];
	[expiresOn release];
	[super dealloc];
}

@end
