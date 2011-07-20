//
//  ReceiptRequest.m
//  InventoryKit
//
//  Created by Aubrey Goodman on 7/3/11.
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
