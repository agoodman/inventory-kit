//
//  IKSubscription.m
//  IKExample
//
//  Created by Aubrey Goodman on 3/7/11.
//  Copyright 2011 Migrant Studios. All rights reserved.
//

#import "IKSubscription.h"


@implementation IKSubscription

@synthesize productIdentifier, expirationDate;

+ (NSString*)getRemoteCollectionName
{
	return @"subscriptions";
}

- (void)dealloc
{
	[productIdentifier release];
	[expirationDate release];
	[super dealloc];
}

@end
