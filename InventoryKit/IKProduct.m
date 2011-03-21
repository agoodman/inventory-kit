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

+ (IKProduct*)productWithDictionary:(NSDictionary*)dictionary
{
	NSLog(@"productWithDictionary: %@",dictionary);
	IKProduct* tProduct = [[[IKProduct alloc] init] autorelease];
	tProduct.productId = [dictionary objectForKey:@"id"];
	tProduct.identifier = [dictionary objectForKey:@"identifier"];
	tProduct.price = [dictionary objectForKey:@"price"];
	tProduct.duration = [dictionary objectForKey:@"duration"];
	tProduct.createdAt = [dictionary objectForKey:@"created_at"];
	tProduct.updatedAt = [dictionary objectForKey:@"updated_at"];
	return tProduct;
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
