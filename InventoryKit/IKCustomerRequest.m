//
//  CustomerRequest.m
//  InventoryKit
//
//  Created by Aubrey Goodman on 7/5/11.
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

#import "IKCustomerRequest.h"
#import "InventoryKit.h"
#import "ASIHTTPRequest.h"
#import "NSString+SHA1.h"


static int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation IKCustomerRequest

+ (void)requestCustomerByEmail:(NSString*)aEmail success:(IKCustomerBlock)successBlock failure:(IKErrorBlock)failureBlock
{
	NSString* tPath = [NSString stringWithFormat:@"%@customers/%@.json",[InventoryKit serverUrl],[[NSString stringWithFormat:@"--%@--",aEmail] secretKey]];
	DDLogVerbose(@"Retrieving %@",tPath);
	
	ASIHTTPRequest* tRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:tPath]];
	[tRequest addBasicAuthenticationHeaderWithUsername:[InventoryKit apiToken] andPassword:@"x"];
	[tRequest setCompletionBlock:^ {
		DDLogVerbose(@"Received: %@",[tRequest responseString]);
		int tStatusCode = [tRequest responseStatusCode];
		if( tStatusCode==200 ) {
			NSString* tJson = [tRequest responseString];
			NSDictionary* tCustomerDict = [tJson JSONValue];
			IKCustomer* tCustomer = [IKCustomer customerWithDictionary:[tCustomerDict objectForKey:@"customer"]];
			successBlock(tCustomer);
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

+ (void)requestCreateCustomerByEmail:(NSString*)aEmail success:(IKCustomerBlock)successBlock failure:(IKErrorBlock)failureBlock
{
	NSString* tPath = [NSString stringWithFormat:@"%@customers.json",[InventoryKit serverUrl]];
	
	ASIHTTPRequest* tRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:tPath]];
	[tRequest addBasicAuthenticationHeaderWithUsername:[InventoryKit apiToken] andPassword:@"x"];
	NSString* tJson = [[NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:aEmail forKey:@"email"] forKey:@"customer"] JSONRepresentation];
	DDLogVerbose(@"Posting to %@ with body: %@",tPath,tJson);
	[tRequest appendPostData:[tJson dataUsingEncoding:NSUTF8StringEncoding]];
	[tRequest addRequestHeader:@"Content-Type" value:@"application/json"];
	[tRequest setRequestMethod:@"POST"];
	[tRequest setCompletionBlock:^ {
		DDLogVerbose(@"Received: %@",[tRequest responseString]);
		int tStatusCode = [tRequest responseStatusCode];
		if( tStatusCode==200 ) {
			NSString* tJson = [tRequest responseString];
			NSDictionary* tCustomerDict = [tJson JSONValue];
			IKCustomer* tCustomer = [IKCustomer customerWithDictionary:[tCustomerDict objectForKey:@"customer"]];
			successBlock(tCustomer);
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

@end
