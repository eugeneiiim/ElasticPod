//
//  AddInstancesViewController.h
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/21/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EC2DataController.h"
#import "LabelCell.h"

typedef enum {NO_SELECTION, KEYNAME_SELECTION, AVAILABILITYZONE_SELECTION, IMAGEID_SELECTION, INSTANCETYPE_SELECTION, NUMINSTANCES_SELECTION} RunInstancesInputSelection;

@interface AddInstancesViewController : UITableViewController <UIAlertViewDelegate> {
	EC2DataController* ec2Controller;
	LabelCell* numinstances_cell;
	LabelCell* imageid_cell;
	LabelCell* keyname_cell;
	LabelCell* availabilityzone_cell;
	LabelCell* instancetype_cell;
	LabelCell* securitygroups_cell;
	LabelCell* kernelid_cell;
	LabelCell* ramdiskid_cell;

	NSMutableString* numinstances_text;
	NSMutableString* imageid_text;
	NSMutableString* keyname_text;
	NSMutableString* availabilityzone_text;
	NSMutableString* instancetype_text;
	//NSMutableString* securitygroups_text;
	NSMutableString* kernelid_text;
	NSMutableString* ramdiskid_text;
	NSMutableArray* security_groups;
	
	RunInstancesInputSelection input_selection;
	BOOL initialrefresh_key;
	BOOL initialrefresh_avail;
	BOOL initialrefresh_securitygroups;

	EC2Instance* model_inst;

	AccountsController* accountsController;
}

@property (nonatomic,readwrite,assign) EC2DataController* ec2Controller;
@property (nonatomic,readwrite,assign) LabelCell* numinstances_cell;
@property (nonatomic,readwrite,assign) LabelCell* imageid_cell;
@property (nonatomic,readwrite,assign) LabelCell* keyname_cell;
@property (nonatomic,readwrite,assign) LabelCell* availabilityzone_cell;
@property (nonatomic,readwrite,assign) LabelCell* instancetype_cell;
@property (nonatomic,readwrite,assign) LabelCell* securitygroups_cell;
@property (nonatomic,readwrite,assign) LabelCell* kernelid_cell;
@property (nonatomic,readwrite,assign) LabelCell* ramdiskid_cell;
@property (nonatomic,readwrite,assign) RunInstancesInputSelection input_selection;
@property (nonatomic,readwrite,assign) BOOL initialrefresh_key;
@property (nonatomic,readwrite,assign) BOOL initialrefresh_avail;
@property (nonatomic,readwrite,assign) BOOL initialrefresh_securitygroups;
@property (nonatomic,readwrite,assign) EC2Instance* model_inst;
@property (nonatomic,readwrite,assign) AccountsController* accountsController;
@property (nonatomic,readwrite,assign) NSMutableString* numinstances_text;
@property (nonatomic,readwrite,assign) NSMutableString* imageid_text;
@property (nonatomic,readwrite,assign) NSMutableString* keyname_text;
@property (nonatomic,readwrite,assign) NSMutableString* availabilityzone_text;
@property (nonatomic,readwrite,assign) NSMutableString* instancetype_text;
@property (nonatomic,readwrite,assign) NSMutableString* kernelid_text;
@property (nonatomic,readwrite,assign) NSMutableString* ramdiskid_text;
@property (nonatomic,readwrite,assign) NSMutableArray* security_groups;

- (IBAction)runInstances:(id)sender;
- (AddInstancesViewController*)initWithStyle:(UITableViewStyle)style ec2Controller:(EC2DataController*)ec2Ctrl accountsController:(AccountsController*)accts_ctrl;
- (void)refreshEC2Callback:(RequestType)rt;
- (void)refresh;

@end
