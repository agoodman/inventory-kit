//
//  IKCustomer.m
//  IKExample
//
//  Created by Aubrey Goodman on 3/7/11.
//  Copyright 2011 Migrant Studios. All rights reserved.
//

#import "IKCustomer.h"
#import "IKSubscription.h"


static int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation IKCustomer

@synthesize customerId, email, subscriptions;

+ (NSString*)getRemoteCollectionName
{
	return @"customers";
}

+ (id)customerWithDictionary:(NSDictionary*)aDictionary
{
	IKCustomer* tCustomer = [[[IKCustomer alloc] init] autorelease];
	tCustomer.customerId = [aDictionary objectForKey:@"id"];
	tCustomer.email = [aDictionary objectForKey:@"email"];
	NSArray* tSubscriptionDicts = [aDictionary objectForKey:@"subscriptions"];
	NSMutableArray* tSubscriptions = [NSMutableArray array];
	for (NSDictionary* dict in tSubscriptionDicts) {
		IKSubscription* tSub = [[[IKSubscription alloc] init] autorelease];
		tSub.productIdentifier = [dict objectForKey:@"product_identifier"];
		tSub.expiresOn = [dict objectForKey:@"expires_on"];
		[tSubscriptions addObject:tSub];
	}
	tCustomer.subscriptions = tSubscriptions;
	return tCustomer;
}

- (void)dealloc
{
	[customerId release];
	[email release];
	[subscriptions release];
	[super dealloc];
}

@end
