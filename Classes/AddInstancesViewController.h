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

@interface AddInstancesViewController : UITableViewController {
	EC2DataController* ec2Controller;
	DetailCell* numinstances_cell;
	DetailCell* imageid_cell;
	DetailCell* keyname_cell;
	DetailCell* availabilityzone_cell;
	DetailCell* instancetype_cell;
}

@property (nonatomic,readwrite,assign) EC2DataController* ec2Controller;
@property (nonatomic,readwrite,assign) DetailCell* numinstances_cell;
@property (nonatomic,readwrite,assign) DetailCell* imageid_cell;
@property (nonatomic,readwrite,assign) DetailCell* keyname_cell;
@property (nonatomic,readwrite,assign) DetailCell* availabilityzone_cell;
@property (nonatomic,readwrite,assign) DetailCell* instancetype_cell;

- (IBAction)runInstances:(id)sender;
- (AddInstancesViewController*)initWithStyle:(UITableViewStyle)style ec2Controller:(EC2DataController*)ec2Ctrl;

@end
