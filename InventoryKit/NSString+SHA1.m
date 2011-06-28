//
//  NSString+SHA1.m
//  IKExample
//
//  Created by Aubrey Goodman on 3/19/11.
//  Copyright 2011 Migrant Studios. All rights reserved.
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
