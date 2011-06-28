//
//  NSString+SHA1.h
//  IKExample
//
//  Created by Aubrey Goodman on 3/19/11.
//  Copyright 2011 Migrant Studios. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (SHA1)

-(NSString*)hexdigest;
-(NSString*)secretKey;

@end
