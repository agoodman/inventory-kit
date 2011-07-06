//
//  ReceiptRequest.m
//  InventoryKit
//
//  Created by Aubrey Goodman on 7/3/11.
//  Copyright 2011 Migrant Studios LLC. All rights reserved.
//

#import "ReceiptRequest.h"
#import "ASIHTTPRequest.h"
#import "NSObject+SBJSON.h"


static int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation ReceiptRequest

+ (void)requestCreateReceipt:(NSData*)aReceipt successBlock:(IKBasicBlock)successBlock failureBlock:(IKErrorBlock)failureBlock
{
	NSString* tPath = [NSString stringWithFormat:@"%@customers/%@/receipts.json",[InventoryKit serverUrl],[[NSString stringWithFormat:@"--%@--",[InventoryKit customerEmail]] secretKey]];
	ASIHTTPRequest* tRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:tPath]];
	[tRequest addBasicAuthenticationHeaderWithUsername:[InventoryKit apiToken] andPassword:@"x"];
	NSDictionary* tReceiptDict = [NSDictionary dictionaryWithObject:[aReceipt base64Encoding] forKey:@"receipt_data"];
	NSString* tJson = [tReceiptDict JSONRepresentation];
	DDLogVerbose(@"posting to %@ with body:\n%@",tPath,tJson);
	[tRequest appendPostData:[tJson dataUsingEncoding:NSUTF8StringEncoding]];
	[tRequest addRequestHeader:@"Content-Type" value:@"application/json"];
	[tRequest setRequestMethod:@"POST"];
	[tRequest setCompletionBlock:^{
		int tStatusCode = [tRequest responseStatusCode];
		DDLogVerbose(@"received: %@",[tRequest responseString]);
		if( tStatusCode==200 ) {
			successBlock();
		}else{
			int tStatusCode = [tRequest responseStatusCode];
			NSString* tResponse = [tRequest responseString];
			failureBlock(tStatusCode, tResponse);
		}
	}];
	[tRequest setFailedBlock:^{
		int tStatusCode = [tRequest responseStatusCode];
		NSString* tResponse = [tRequest responseString];
		DDLogVerbose(@"error: %@",tResponse);
		failureBlock(tStatusCode, tResponse);
	}];
	[tRequest startAsynchronous];
}

@end
