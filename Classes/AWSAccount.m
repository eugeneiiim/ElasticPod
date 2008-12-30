//
//  AWSAccount.m
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/18/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import "AWSAccount.h"

@implementation AWSAccount

@synthesize name, access_key, secret_key, defaultImageId, defaultRamdiskId, defaultKernelId;

+ (id)accountWithName:(NSString*)name_ accessKey:(NSString*)ak secretKey:(NSString*)sk {
	return [[[AWSAccount alloc] initWithName:[name_ copy] accessKey:[ak copy] secretKey:[sk copy]] autorelease];
}

- (id)initWithName:(NSString*)name_ accessKey:(NSString*)ak secretKey:(NSString*)sk {
	self.name = name_;
	self.access_key = ak;
	self.secret_key = sk;
	self.defaultImageId = nil;
	self.defaultRamdiskId = nil;
	self.defaultKernelId = nil;
	return self;
}

@end
