//
//  EC2Instance.h
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/18/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EC2Instance : NSObject {
	NSString* instanceId;
}

@property (nonatomic, copy, readwrite) NSString* instanceId;
- (id)init:(NSString*)id_;

@end
