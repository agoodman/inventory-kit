//
//  ProductRequest.m
//  InventoryKit
//
//  Created by Aubrey Goodman on 3/20/11.
//  Copyright 2011 Migrant Studios LLC. All rights reserved.
//

#import "ProductRequest.h"
#import "ASIHTTPRequest.h"
#import "InventoryKit.h"
#import "SBJSON.h"


static int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation ProductRequest

+ (void)requestProductsWithSuccessBlock:(ProductIndexSuccessBlock)successBlock failureBlock:(ProductFailureBlock)failureBlock
{
	NSString* tServerUrl = [InventoryKit serverUrl];
	NSString* tPath = [NSString stringWithFormat:@"%@products.json",tServerUrl];
	DDLogVerbose(@"Retrieving products from %@",tPath);
	NSURL* tUrl = [NSURL URLWithString:tPath];
	ASIHTTPRequest* tRequest = [ASIHTTPRequest requestWithURL:tUrl];
	[tRequest addBasicAuthenticationHeaderWithUsername:[InventoryKit apiToken] andPassword:@"x"];
	[tRequest setCompletionBlock:^ {
		int tStatusCode = [tRequest responseStatusCode];
		if( tStatusCode==200 ) {
			NSString* tJson = [tRequest responseString];
			NSArray* tProductDicts = [tJson JSONValue];
			NSMutableArray* tProducts = [[NSMutableArray alloc] init];
			for (NSDictionary* dict in tProductDicts) {
				IKProduct* tProduct = [IKProduct productWithDictionary:[dict objectForKey:@"product"]];
				[tProducts addObject:tProduct];
			}
			successBlock(tProducts);
			[tProducts release];
		}else{
			failureBlock();
		}
	}];
	[tRequest setFailedBlock:^ {
		failureBlock();
	}];
	[tRequest startAsynchronous];
}

+ (void)requestUpdateProduct:(IKProduct *)aProduct successBlock:(ProductUpdateSuccessBlock)successBlock failureBlock:(ProductFailureBlock)failureBlock
{
	NSString* tServerUrl = [InventoryKit serverUrl];
	NSString* tPath = [NSString stringWithFormat:@"%@products/%@.json",tServerUrl,[[NSString stringWithFormat:@"--%@--",aProduct.identifier] secretKey]];
	DDLogVerbose(@"Updating product at %@",tPath);
	
	NSURL* tUrl = [NSURL URLWithString:tPath];
	ASIHTTPRequest* tRequest = [ASIHTTPRequest requestWithURL:tUrl];
	[tRequest addBasicAuthenticationHeaderWithUsername:[InventoryKit apiToken] andPassword:@"x"];
	[tRequest setRequestMethod:@"PUT"];
	
	NSDictionary* tProductDict = [aProduct dictionaryWithValuesForKeys:[NSArray arrayWithObject:@"price"]];
	NSString* tJson = [[NSDictionary dictionaryWithObject:tProductDict forKey:@"product"] JSONRepresentation];
	[tRequest addRequestHeader:@"Content-Type" value:@"application/json"];
	[tRequest appendPostData:[tJson dataUsingEncoding:NSISOLatin1StringEncoding]];
	
	[tRequest setCompletionBlock:^ {
		int tStatusCode = [tRequest responseStatusCode];
		if( tStatusCode==200 ) {
			successBlock(aProduct);
		}else{
			failureBlock();
		}
	}];
	[tRequest setFailedBlock:^ {
		failureBlock();
	}];
	[tRequest startAsynchronous];
}

@end
