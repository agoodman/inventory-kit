//
//  IKProduct.m
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

#import "IKProduct.h"


@implementation IKProduct

@synthesize productId, identifier, price, duration, createdAt, updatedAt;

+ (NSString*)getRemoteCollectionName
{
	return @"products";
}

+ (IKProduct*)productWithDictionary:(NSDictionary*)dictionary
{
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
