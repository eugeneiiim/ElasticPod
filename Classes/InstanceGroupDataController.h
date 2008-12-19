//
//  InstanceGroupDataController.h
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/19/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EC2InstanceGroup.h"

@interface InstanceGroupDataController : NSObject {
  EC2InstanceGroup* instance_group;
  NSMutableArray *list;
}

- (unsigned)countOfList;
- (id)objectInListAtIndex:(unsigned)theIndex;
@property (nonatomic, copy, readwrite) NSMutableArray *list;
@property (nonatomic, copy, readwrite) EC2InstanceGroup *instance_group;
- (void)requestInstanceGroupInstances;
- (id)init:(EC2InstanceGroup*)grp;

@end
