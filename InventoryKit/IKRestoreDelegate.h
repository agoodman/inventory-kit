/*
 *  IKRestoreDelegate.h
 *  InventoryKit
 *
 *  Created by Aubrey Goodman on 11/13/09.
 *  Copyright 2009 Migrant Studios LLC. All rights reserved.
 *
 */

@protocol IKRestoreDelegate

-(void)productsRestored;
-(void)productRestoreFailed:(NSError*)error;
  
@end
