//
//  InstanceGroupViewController.h
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/19/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EC2DataController.h";

@interface InstanceGroupViewController : UITableViewController {
	EC2DataController* ec2Controller;
	NSString* instanceGroup;
	AccountsController* accountsController;
}

@property (nonatomic, readwrite, assign) EC2DataController* ec2Controller;
@property (nonatomic, readwrite, assign) NSString* instanceGroup;
@property (nonatomic, readwrite, assign) AccountsController* accountsController;

- (void)refresh;
- (InstanceGroupViewController*)initWithStyle:(UITableViewStyle)style instanceGroup:(NSString*)grp ec2Controller:(EC2DataController*)ec2Ctrl accountsController:(AccountsController*)accts_ctrl;
- (void)refreshEC2Callback:(RequestType)rt;
- (void)resizeTable;

@end
