//
//  IKSubscription.m
//  IKExample
//
//  Created by Aubrey Goodman on 3/7/11.
//  Copyright 2011 Migrant Studios. All rights reserved.
//

#import "IKSubscription.h"


@implementation IKSubscription

@synthesize productIdentifier, expiresOn;

+ (NSString*)getRemoteCollectionName
{
	return @"subscriptions";
}

- (void)dealloc
{
	[productIdentifier release];
	[expiresOn release];
	[super dealloc];
}

@end
