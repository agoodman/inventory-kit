//
//  IKExampleViewController.m
//  IKExample
//
//  Created by Aubrey Goodman on 1/21/11.
//  Copyright 2011 Migrant Studios LLC. All rights reserved.
//

#import "IKExampleViewController.h"
#import "InventoryKit.h"


@implementation IKExampleViewController

@synthesize activateView, resetView;

- (void)checkActivation
{
	// check for product activation
	BOOL tIsActive = [InventoryKit productActivated:kProductKey];
	
	// conditionally configure view component visibility
	if( tIsActive ) {
		activateView.hidden = YES;
		resetView.hidden = NO;
	}else{
		activateView.hidden = NO;
		resetView.hidden = YES;
	}
}

#pragma mark -
#pragma mark IBActions

- (IBAction)activateProduct
{
	[InventoryKit activateProduct:kProductKey];
	[self checkActivation];
}

- (IBAction)resetProduct
{
	[InventoryKit deactivateProduct:kProductKey];
	[self checkActivation];
}

#pragma mark -
#pragma mark View Lifecycle

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	[self checkActivation];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
