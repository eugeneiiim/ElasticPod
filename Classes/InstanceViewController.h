//
//  InstanceViewController.h
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/19/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EC2Instance.h"
#import "EC2DataController.h"
#import "InstanceGroupViewController.h"

typedef enum {REBOOT, TERMINATE, NO_ACTION} InstanceAction;

@interface InstanceViewController : UITableViewController <UIAlertViewDelegate> {
	EC2Instance* instance;
	EC2DataController* ec2Controller;
	NSInteger index;
	NSString* group;
	UITableViewCell* reboot_cell;
	UITableViewCell* terminate_cell;
	InstanceAction lastAction;
	AccountsController* accountsController;
}

@property (nonatomic, readwrite, assign) EC2Instance* instance;
@property (nonatomic, readwrite, assign) EC2DataController* ec2Controller;
@property (nonatomic, readwrite, assign) NSInteger index;
@property (nonatomic, readwrite, assign) NSString* group;
@property (nonatomic, readwrite, assign) UITableViewCell* reboot_cell;
@property (nonatomic, readwrite, assign) UITableViewCell* terminate_cell;
@property (nonatomic, readwrite, assign) InstanceAction lastAction;
@property (nonatomic, readwrite, assign) AccountsController* accountsController;

- (InstanceViewController*)initWithStyle:(UITableViewStyle)style instance:(EC2Instance*)inst ec2Controller:(EC2DataController*)ec2Ctrl group:(NSString*)group accountsController:(AccountsController*)accts_ctrl;
- (void)refreshEC2Callback:(RequestType)rt;
- (void)resizeTable;
- (BOOL)showRebootButton;
- (BOOL)showTerminateButton;
- (void)rebootConfirmation;
- (void)terminateConfirmation;

@end
