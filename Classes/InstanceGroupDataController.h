//
//  InstanceGroupDataController.h
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/19/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>

#import	"AWSAccount.h"
#import "EC2Instance.h"
#import "EC2DataController.h"

@class InstanceGroupViewController;

@interface InstanceGroupDataController : NSObject {
	NSString* instance_group;
	InstanceGroupViewController* viewController;
	AWSAccount* account;
	NSMutableData* urlreq_data;
	NSInteger inReservationElement;
	NSString* lastElementName;
	EC2Instance* curInst;
	EC2DataController* ec2Controller;
}

@property (nonatomic, copy, readwrite) NSString* instance_group;
@property (nonatomic, copy, readonly) InstanceGroupViewController* viewController;
@property (nonatomic, readwrite) NSInteger inReservationElement;
@property (nonatomic, copy, readwrite) AWSAccount* account;
@property (nonatomic, copy, readwrite) NSMutableData* urlreq_data;
@property (nonatomic, copy, readwrite) NSString* lastElementName;
@property (nonatomic, copy, readonly) EC2Instance* curInst;
@property (nonatomic, assign, readwrite) EC2DataController* ec2Controller;

- (unsigned)countOfList;
- (EC2Instance*)objectInListAtIndex:(unsigned)theIndex;
- (id)init:(NSString*)grp viewController:(InstanceGroupViewController*)vc account:(AWSAccount*)a ec2Controller:(EC2DataController*)ec2ctrl;
- (void)removeInstanceAtIndex:(NSInteger)index;
- (void)refresh;
- (NSArray*)list;

@end
