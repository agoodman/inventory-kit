//
//  IKProductObserver.m
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

#import "IKProductObserver.h"
#import "IKProduct.h"
#import "IKApiClient.h"


static int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation IKProductObserver

- (void)productsRequest:(SKProductsRequest*)request didReceiveResponse:(SKProductsResponse*)response
{
	NSString* tPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"IKSubscriptionPrices.plist"];
	NSDictionary* tOldSubscriptionPrices = [NSDictionary dictionaryWithContentsOfFile:tPath];

	NSMutableDictionary* tSubscriptionPrices = [[NSMutableDictionary alloc] initWithDictionary:tOldSubscriptionPrices];
	NSMutableSet* tDeltas = [[NSMutableSet alloc] init];
	
	if( response.invalidProductIdentifiers.count>0 ) {
		DDLogVerbose(@"invalid products: %@",response.invalidProductIdentifiers);
	}
	
	for (SKProduct* product in response.products) {
		NSLocale* tLocale = product.priceLocale;
		DDLogVerbose(@"productId: %@, locale: %@, price: %@",product.productIdentifier,tLocale.localeIdentifier,product.price);
		
		// only use USD prices
		if( [tLocale.localeIdentifier isEqualToString:@"en_US@currency=USD"] ) {
			float tDollars = [product.price floatValue];
			NSNumber* tSubscriptionPrice = [tSubscriptionPrices objectForKey:product.productIdentifier];
			if( fabs(tDollars-[tSubscriptionPrice floatValue])>0.01 ) {
				[tDeltas addObject:product.productIdentifier];
				[tSubscriptionPrices setObject:[NSNumber numberWithFloat:tDollars] forKey:product.productIdentifier];
			}
		}
	}
	
	if( tDeltas.count>0 ) {
		// push updated product prices to web service
		NSMutableSet* tProducts = [[NSMutableSet alloc] init];
		for (NSString* productId in tDeltas) {
			IKProduct* tProduct = [[[IKProduct alloc] init] autorelease];
			tProduct.identifier = productId;
			tProduct.price = [tSubscriptionPrices objectForKey:productId];
			[tProducts addObject:tProduct];
		}
		[IKApiClient updateProducts:tProducts];
		if( [tSubscriptionPrices writeToFile:tPath atomically:YES] ) {
			DDLogVerbose(@"Successfully updated local product prices");
		}else{
			DDLogVerbose(@"Unable to save product prices");
		}
		[tProducts release];
	}
	
	[tDeltas release];
	[tSubscriptionPrices release];
}

@end
