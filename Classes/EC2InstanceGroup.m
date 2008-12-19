//
//  EC2InstanceGroup.m
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/18/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import "EC2InstanceGroup.h"

@implementation EC2InstanceGroup

@synthesize instanceGroupId;

- (id)initWithInstanceGroupId:(NSString*)group_id {
  self.instanceGroupId = group_id;
  return self;
}

@end
