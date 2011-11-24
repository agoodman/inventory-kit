//
//  ProductRequest.m
//  InventoryKit
//
//  Created by Aubrey Goodman on 3/20/11.
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

#import "IKProductRequest.h"
#import "ASIHTTPRequest.h"
#import "InventoryKit.h"


static int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation IKProductRequest

+ (void)requestProductsWithSuccessBlock:(IKArrayBlock)successBlock failureBlock:(IKErrorBlock)failureBlock
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
			int tStatusCode = [tRequest responseStatusCode];
			NSString* tResponse = [tRequest responseString];
			failureBlock(tStatusCode, tResponse);
		}
	}];
	[tRequest setFailedBlock:^ {
		int tStatusCode = [tRequest responseStatusCode];
		NSString* tResponse = [tRequest responseString];
		failureBlock(tStatusCode, tResponse);
	}];
	[tRequest startSynchronous];
}

+ (void)requestUpdateProduct:(IKProduct *)aProduct successBlock:(IKProductBlock)successBlock failureBlock:(IKErrorBlock)failureBlock
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
			int tStatusCode = [tRequest responseStatusCode];
			NSString* tResponse = [tRequest responseString];
			failureBlock(tStatusCode, tResponse);
		}
	}];
	[tRequest setFailedBlock:^ {
		int tStatusCode = [tRequest responseStatusCode];
		NSString* tResponse = [tRequest responseString];
		failureBlock(tStatusCode, tResponse);
	}];
	[tRequest startAsynchronous];
}

@end
