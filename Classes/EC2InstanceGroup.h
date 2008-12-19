//
//  EC2InstanceGroup.h
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/18/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EC2InstanceGroup : NSObject {
  NSString* instanceGroupId;
}

@property (nonatomic, copy, readwrite) NSString* instanceGroupId;
- (id)initWithInstanceGroupId:(NSString*)group_id;

@end
