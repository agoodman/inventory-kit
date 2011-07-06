//
//  IKSubscription.h
//  IKExample
//
//  Created by Aubrey Goodman on 3/7/11.
//  Copyright 2011 Migrant Studios. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IKSubscription : NSObject {

	NSString* productIdentifier;
	NSDate* expiresOn;
	
}

@property (retain) NSString* productIdentifier;
@property (retain) NSDate* expiresOn;

@end
