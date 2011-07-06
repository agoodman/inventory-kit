//
//  CustomerRequest.m
//  Uptimetry
//
//  Created by Aubrey Goodman on 7/5/11.
//  Copyright 2011 Migrant Studios LLC. All rights reserved.
//

#import "CustomerRequest.h"
#import "InventoryKit.h"
#import "ASIHTTPRequest.h"
#import "NSString+SHA1.h"


static int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation CustomerRequest

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
