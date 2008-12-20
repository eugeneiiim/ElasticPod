//
//  InstanceGroupSetDataController.m
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/18/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import "InstanceGroupSetViewController.h"
#import "InstanceGroupSetDataController.h"
#import "EC2InstanceGroup.h"
#import "EC2DataController.h"

@implementation InstanceGroupSetDataController

@synthesize account, viewController, ec2Controller;

- (id)initWithAccount:(AWSAccount*)acct viewController:(InstanceGroupSetViewController*)vc ec2Controller:(EC2DataController*)ec2ctrl {
	if (self = [super init]) {
		self.account = acct;
		self.viewController = vc;
		self.ec2Controller = ec2ctrl;
	}

	return self;
}

- (NSArray*)list {
	return [ec2Controller getInstanceGroups];
}

- (void)refresh {
	[ec2Controller refreshInstanceData];
}

- (unsigned)countOfList {
	return [[self list] count];
}

- (id)objectInListAtIndex:(unsigned)theIndex {
	return [[self list] objectAtIndex:theIndex];
}

- (void)dealloc {
	[super dealloc];
}

- (void)removeGroupAtIndex:(NSInteger)index {
	NSString* grp = [[self list] objectAtIndex:index];
	[ec2Controller terminateInstances:[ec2Controller getInstancesForGroup:grp]];
}

@end
