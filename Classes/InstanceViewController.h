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

@interface InstanceViewController : UITableViewController {
	EC2Instance* instance;
	EC2DataController* ec2Controller;
}

@property (nonatomic, readwrite, assign) EC2Instance* instance;
@property (nonatomic, readwrite, assign) EC2DataController* ec2Controller;


@end
