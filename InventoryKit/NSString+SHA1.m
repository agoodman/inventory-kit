//
//  NSString+SHA1.m
//  InventoryKit
//
//  Created by Aubrey Goodman on 3/19/11.
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

#import "NSString+SHA1.h"
#import <CommonCrypto/CommonDigest.h>


@implementation NSString (SHA1)

- (NSString*)hexdigest
{
	NSData* tStringData = [self dataUsingEncoding:NSUTF8StringEncoding];
	unsigned char tHashBytes[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1([tStringData bytes], [self length], tHashBytes);
	
    NSData* tRawHash = [NSData dataWithBytes:tHashBytes length:CC_SHA1_DIGEST_LENGTH];
	NSString* tHex = [tRawHash description];
	tHex = [tHex stringByReplacingOccurrencesOfString:@"<" withString:@""];
	tHex = [tHex stringByReplacingOccurrencesOfString:@">" withString:@""];
	tHex = [tHex stringByReplacingOccurrencesOfString:@" " withString:@""];
	return tHex;
}

- (NSString*)secretKey
{
	return [[self hexdigest] substringToIndex:10];
}

@end
