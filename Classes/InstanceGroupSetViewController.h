//
//  InstanceGroupSetViewController.h
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/18/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "InstanceGroupSetDataController.h"

@interface InstanceGroupSetViewController : UITableViewController {
  InstanceGroupSetDataController* dataController;
}

@property (nonatomic, retain) InstanceGroupSetDataController *dataController;
- (IBAction)addInstanceGroup:(id)sender;

@end
