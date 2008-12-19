//
//  EC2Instance.m
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/18/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import "EC2Instance.h"

@implementation EC2Instance

@synthesize instanceId;

- (id)init:(NSString*)id_ {
	instanceId = id_;
	return self;
}



@end
