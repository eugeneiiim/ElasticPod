//
//  InstanceGroupSetViewController.h
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/18/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EC2DataController.h"

@class InstanceGroupSetDataController;

@interface InstanceGroupSetViewController : UITableViewController {
	EC2DataController* ec2Controller;
	AWSAccount* account;
}

@property (nonatomic, assign, readwrite) EC2DataController* ec2Controller;
@property (nonatomic, assign, readwrite) AWSAccount* account;

- (IBAction)addInstanceGroup:(id)sender;
- (void)refresh;
- (InstanceGroupSetViewController*)initWithStyle:(UITableViewStyle)style account:(AWSAccount*)acct ec2Controller:(EC2DataController*)ec2Ctrl;
- (void)refreshEC2Callback;

@end
