//
//  EC2Instance.h
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/18/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EC2Instance : NSObject {
	NSMutableDictionary* instanceProperties;
	NSArray* securityGroups;
}

@property (nonatomic, assign, readwrite) NSMutableDictionary* instanceProperties;
@property (nonatomic, readwrite, assign) NSArray* securityGroups;

- (id)init;
- (NSString*)getProperty:(NSString*)key;
- (void)addProperty:(NSString*)key value:(NSString*)value;

@end
