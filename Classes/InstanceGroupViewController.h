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
}

@property (nonatomic, readwrite, assign) EC2DataController* ec2Controller;
@property (nonatomic, readwrite, assign) NSString* instanceGroup;

- (IBAction)addInstances:(id)sender;
- (void)refresh;
- (InstanceGroupViewController*)initWithStyle:(UITableViewStyle)style instanceGroup:(NSString*)grp ec2Controller:(EC2DataController*)ec2Ctrl;
- (void)refreshEC2Callback;

@end
