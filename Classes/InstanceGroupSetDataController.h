//
//  InstanceGroupSetDataController.h
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/18/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AWSAccount.h"
#import "InstanceGroupSetViewController.h"
#import "EC2DataController.h"

@class InstanceGroupSetViewController;

@interface InstanceGroupSetDataController : NSObject {
	AWSAccount* account;
	InstanceGroupSetViewController* viewController;
	EC2DataController* ec2Controller;
}

@property (nonatomic, readwrite, assign) InstanceGroupSetViewController* viewController;
@property (nonatomic, readwrite, assign) EC2DataController* ec2Controller;
@property (nonatomic, readwrite, assign) AWSAccount *account;

- (unsigned)countOfList;
- (id)objectInListAtIndex:(unsigned)theIndex;
- (id)initWithAccount:(AWSAccount*)acct viewController:(InstanceGroupSetViewController*)vc ec2Controller:(EC2DataController*)ec2Ctrl;
- (void)removeGroupAtIndex:(NSInteger)index;
- (void)refresh;
- (NSArray*)list;

@end
