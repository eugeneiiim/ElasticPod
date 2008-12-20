//
//  AddInstancesViewController.h
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/21/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "InstanceGroupSetDataController.h"

@interface AddInstancesViewController : UIViewController {
	EC2DataController* ec2Controller;
}

@property (readwrite,assign) EC2DataController* ec2Controller;

- (IBAction)addInstances:(id)sender;

@end
