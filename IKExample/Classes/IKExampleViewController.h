//
//  IKExampleViewController.h
//  IKExample
//
//  Created by Aubrey Goodman on 1/21/11.
//  Copyright 2011 Migrant Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kProductKey @"com.migrant.inventorykit.example"


@interface IKExampleViewController : UIViewController {

	IBOutlet UIView* activateView;
	IBOutlet UIView* resetView;
	
}

@property (retain) UIView* activateView;
@property (retain) UIView* resetView;

-(IBAction)activateProduct;
-(IBAction)resetProduct;

@end

