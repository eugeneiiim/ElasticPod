//
//  AWSAccount.m
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/18/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import "AWSAccount.h"

@implementation AWSAccount

@synthesize access_key;
@synthesize secret_key;

- (id)init:(NSString*)ak secret_key:(NSString*)sk {
	access_key = ak;
	secret_key = sk;
	return self;
}

@end
