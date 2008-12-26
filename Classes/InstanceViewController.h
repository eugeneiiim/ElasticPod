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

@interface InstanceViewController : UITableViewController {
	EC2Instance* instance;
	EC2DataController* ec2Controller;
	NSInteger index;
	NSString* group;
}

@property (nonatomic, readwrite, assign) EC2Instance* instance;
@property (nonatomic, readwrite, assign) EC2DataController* ec2Controller;
@property (nonatomic, readwrite, assign) NSInteger index;
@property (nonatomic, readwrite, assign) NSString* group;

- (id)initWithStyle:(UITableViewStyle) instance:(EC2Instance*)inst ec2Controller:(EC2DataController*)ec2Ctrl group:(NSString*)group;

@end
