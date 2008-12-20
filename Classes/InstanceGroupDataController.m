//
//  InstanceGroupDataController.m
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/19/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import "InstanceGroupDataController.h"
#import "EC2Instance.h"
#import	"AWSAccount.h"
#import "EC2DataController.h"

@implementation InstanceGroupDataController

@synthesize instance_group, viewController, inReservationElement, account, lastElementName, urlreq_data, curInst, ec2Controller;

- (id)init:(NSString*)grp viewController:(InstanceGroupViewController*)vc account:(AWSAccount*)a ec2Controller:(EC2DataController*)ec2ctrl {
	instance_group = grp;
	viewController = vc;
	account = a;
	ec2Controller = ec2ctrl;

//	if (self = [super init]) {	}
	
	return self;
}

- (NSArray*)list {
	return [ec2Controller getInstancesForGroup:instance_group];
}

- (unsigned)countOfList {
	return [[self list] count];
}

- (void)refresh {
}

- (EC2Instance*)objectInListAtIndex:(unsigned)theIndex {
	NSLog(@"instance id returned: %@", [[[self list] objectAtIndex:theIndex] getProperty:@"instanceId"]);
	return [[self list] objectAtIndex:theIndex];
}

- (void)removeInstanceAtIndex:(NSInteger)index {
	EC2Instance* inst = [[self list] objectAtIndex:index];
	[ec2Controller terminateInstances:[NSArray arrayWithObject:inst]];
}

@end
