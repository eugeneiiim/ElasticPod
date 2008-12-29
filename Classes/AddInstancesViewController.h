//
//  AddInstancesViewController.h
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/21/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EC2DataController.h"
#import "DetailCell.h"

typedef enum {NO_SELECTION, KEYNAME_SELECTION, AVAILABILITYZONE_SELECTION, IMAGEID_SELECTION, INSTANCETYPE_SELECTION, NUMINSTANCES_SELECTION} RunInstancesInputSelection;

@interface AddInstancesViewController : UITableViewController <UIAlertViewDelegate, UIPickerViewDelegate> {
	EC2DataController* ec2Controller;
	DetailCell* numinstances_cell;
	DetailCell* imageid_cell;
	DetailCell* keyname_cell;
	DetailCell* availabilityzone_cell;
	DetailCell* instancetype_cell;
	
	UIPickerView* keyname_picker;
	UIPickerView* availabilityzone_picker;
	UIPickerView* imageid_picker;
	UIPickerView* instancetype_picker;

	RunInstancesInputSelection input_selection;
}

@property (nonatomic,readwrite,assign) EC2DataController* ec2Controller;
@property (nonatomic,readwrite,assign) DetailCell* numinstances_cell;
@property (nonatomic,readwrite,assign) DetailCell* imageid_cell;
@property (nonatomic,readwrite,assign) DetailCell* keyname_cell;
@property (nonatomic,readwrite,assign) DetailCell* availabilityzone_cell;
@property (nonatomic,readwrite,assign) DetailCell* instancetype_cell;
@property (nonatomic,readwrite,assign) UIPickerView* keyname_picker;
@property (nonatomic,readwrite,assign) UIPickerView* availabilityzone_picker;
@property (nonatomic,readwrite,assign) UIPickerView* imageid_picker;
@property (nonatomic,readwrite,assign) UIPickerView* instancetype_picker;
@property (nonatomic,readwrite,assign) RunInstancesInputSelection input_selection;

- (IBAction)runInstances:(id)sender;
- (AddInstancesViewController*)initWithStyle:(UITableViewStyle)style ec2Controller:(EC2DataController*)ec2Ctrl;
- (void)refreshEC2Callback;
- (void)refresh;

@end
