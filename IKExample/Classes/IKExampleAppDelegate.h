//
//  IKExampleAppDelegate.h
//  IKExample
//
//  Created by Aubrey Goodman on 1/21/11.
//  Copyright 2011 Migrant Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IKExampleViewController;

@interface IKExampleAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    IKExampleViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet IKExampleViewController *viewController;

@end

