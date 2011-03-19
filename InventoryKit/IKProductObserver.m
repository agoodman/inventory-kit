//
//  IKProductObserver.m
//  IKExample
//
//  Created by Aubrey Goodman on 3/7/11.
//  Copyright 2011 Migrant Studios. All rights reserved.
//

#import "IKProductObserver.h"
#import "IKProduct.h"
#import "IKApiClient.h"


@implementation IKProductObserver

- (void)productsRequest:(SKProductsRequest*)request didReceiveResponse:(SKProductsResponse*)response
{
	NSString* tPath = [[NSBundle mainBundle] pathForResource:@"IKSubscriptionPrices" ofType:@"plist"];
	NSDictionary* tOldSubscriptionPrices = [NSDictionary dictionaryWithContentsOfFile:tPath];

	NSMutableDictionary* tSubscriptionPrices = [[NSMutableDictionary alloc] initWithDictionary:tOldSubscriptionPrices];
	NSMutableSet* tDeltas = [[NSMutableSet alloc] init];
	
	for (SKProduct* product in response.products) {
		NSLocale* tLocale = product.priceLocale;
		// only use USD prices
		if( [tLocale.localeIdentifier isEqualToString:@"en_US"] ) {
			float tDollars = [product.price floatValue];
			NSNumber* tSubscriptionPrice = [tSubscriptionPrices objectForKey:product.productIdentifier];
			if( fabs(tDollars-[tSubscriptionPrice floatValue])>0.01 ) {
				[tDeltas addObject:product.productIdentifier];
				[tSubscriptionPrices setObject:tSubscriptionPrice forKey:product.productIdentifier];
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
		[IKApiClient pushProducts:tProducts];
		[tSubscriptionPrices writeToFile:tPath atomically:YES];
		[tProducts release];
	}
	
	[tDeltas release];
	[tSubscriptionPrices release];
}

@end
