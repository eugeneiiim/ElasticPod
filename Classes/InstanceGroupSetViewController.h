//
//  InstanceGroupSetViewController.h
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/18/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "InstanceGroupSetDataController.h"
#import "EC2DataController.h"

@class InstanceGroupSetDataController;

@interface InstanceGroupSetViewController : UITableViewController {
	InstanceGroupSetDataController* dataController;
	EC2DataController* ec2Controller;
}

@property (nonatomic, retain) InstanceGroupSetDataController *dataController;
@property (nonatomic, assign, readwrite) EC2DataController* ec2Controller;

- (IBAction)addInstanceGroup:(id)sender;
- (void)refresh;

@end
