//
//  InstanceGroupSetDataController.m
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/18/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import "InstanceGroupSetDataController.h"
#import "EC2InstanceGroup.h"

@implementation InstanceGroupSetDataController

@synthesize list;
@synthesize account;

- (id)init:(AWSAccount*)acct {
	if (self = [super init]) {
      [self requestAccountInstanceGroups];
    }

    account = acct;
    return self;
}

- (void)setList:(NSMutableArray *)newList {
  if (list != newList) {
    [list release];
    list = [newList mutableCopy];
  }
}

- (unsigned)countOfList {
  return [list count];
}

- (id)objectInListAtIndex:(unsigned)theIndex {
    return [list objectAtIndex:theIndex];
}

- (void)dealloc {
  [list release];
  [super dealloc];
}

- (void)requestAccountInstanceGroups {
  // TODO request account instance groups
  NSMutableArray* instanceGroupList = [[NSMutableArray alloc] init];
  EC2InstanceGroup* ig = [[EC2InstanceGroup alloc] initWithInstanceGroupId:@"asdfasdfasdf"];

  [instanceGroupList addObject:ig];
  self.list = instanceGroupList;

  [instanceGroupList release];
}

@end
