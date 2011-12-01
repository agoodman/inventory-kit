//
//  IKCustomer.m
//  InventoryKit
//
//  Created by Aubrey Goodman on 3/7/11.
//  Copyright 2011 Migrant Studios LLC. 
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//

#import "IKCustomer.h"
#import "IKSubscription.h"


static int ddLogLevel = LOG_LEVEL_WARN;

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
		tSub.expirationDate = [dict objectForKey:@"expiration_date"];
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
