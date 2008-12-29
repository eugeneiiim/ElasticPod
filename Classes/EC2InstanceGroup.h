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
	//NSMutableArray* securityGroups;
}

@property (nonatomic, copy, readwrite) NSString* instanceGroupId;
//@property (nonatomic, readwrite, assign) NSMutableArray* securityGroups;

- (id)initWithInstanceGroupId:(NSString*)group_id;

@end
