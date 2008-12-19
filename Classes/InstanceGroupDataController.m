//
//  InstanceGroupDataController.m
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/19/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import "InstanceGroupDataController.h"
#import "EC2Instance.h"

@implementation InstanceGroupDataController

@synthesize list;
@synthesize instance_group;

- (id)init:(EC2InstanceGroup*)grp {
  if (self = [super init]) {
    [self requestInstanceGroupInstances];
  }

  instance_group = grp;
  return self;
}

- (unsigned)countOfList {
  return [list count];
}

- (id)objectInListAtIndex:(unsigned)theIndex {
  return [list objectAtIndex:theIndex];
}

- (void)requestInstanceGroupInstances {
  // TODO request instances for this group
  NSMutableArray* instanceList = [[NSMutableArray alloc] init];
  EC2Instance* i = [[EC2Instance alloc] init:@"qweqwerqwerqewr"];

  [instanceList addObject:i];
  self.list = instanceList;

  [instanceList release];
}

@end
