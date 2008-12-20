//
//  EC2Instance.m
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/18/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import "EC2Instance.h"

@implementation EC2Instance

@synthesize instanceProperties;

- (id)init {
	instanceProperties = [[NSMutableDictionary alloc] init];
	return self;
}

- (void)addProperty:(NSString*)key value:(NSString*)value {
	[instanceProperties setValue:value forKey:key];
}

- (NSString*)getProperty:(NSString*)key {
	return [instanceProperties valueForKey:key];
}

@end
