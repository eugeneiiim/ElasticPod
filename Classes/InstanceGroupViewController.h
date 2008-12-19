//
//  InstanceGroupViewController.h
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/19/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "InstanceGroupDataController.h"

@interface InstanceGroupViewController : UITableViewController {
  InstanceGroupDataController* dataController;
}

@property (nonatomic, retain) InstanceGroupDataController *dataController;
- (IBAction)addInstances:(id)sender;

@end
