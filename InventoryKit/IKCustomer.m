//
//  IKCustomer.m
//  IKExample
//
//  Created by Aubrey Goodman on 3/7/11.
//  Copyright 2011 Migrant Studios. All rights reserved.
//

#import "IKCustomer.h"


@implementation IKCustomer

@synthesize customerId, email;

+ (NSString*)getRemoteCollectionName
{
	return @"customers";
}

- (void)dealloc
{
	[customerId release];
	[email release];
	[super dealloc];
}

@end
