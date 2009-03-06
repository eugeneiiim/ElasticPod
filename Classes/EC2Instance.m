//
//  EC2Instance.m
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/18/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import "EC2Instance.h"

@implementation EC2Instance

@synthesize instanceProperties, securityGroups, consoleOutput;

- (id)init {
	self.instanceProperties = [[NSMutableDictionary alloc] init];
	self.securityGroups = [[NSArray alloc] init];
	self.consoleOutput = @"";
	return self;
}

- (void)dealloc {
	[self.instanceProperties release];
	[self.securityGroups release];
	[super dealloc];
}

- (void)addProperty:(NSString*)key value:(NSString*)value {
	[instanceProperties setValue:value forKey:key];
}

- (NSString*)getProperty:(NSString*)key {
	return [instanceProperties valueForKey:key];
}

- (void)setSecurityGroups:(NSArray*)newarr {
	if (securityGroups != newarr) {
		[securityGroups release];
		securityGroups = [newarr mutableCopy];
	}
}

@end
