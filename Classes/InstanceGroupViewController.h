//
//  InstanceGroupViewController.h
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/19/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "InstanceGroupDataController.h"
#import "EC2DataController.h";

@interface InstanceGroupViewController : UITableViewController {
	InstanceGroupDataController* dataController;
	EC2DataController* ec2Controller;
}

@property (nonatomic, retain) InstanceGroupDataController *dataController;
@property (nonatomic, readwrite, assign) EC2DataController* ec2Controller;

- (IBAction)addInstances:(id)sender;
- (void)refresh;

@end
