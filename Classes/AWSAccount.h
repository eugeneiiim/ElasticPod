//
//  AWSAccount.h
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/18/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AWSAccount : NSObject {
	NSString* access_key;
	NSString* secret_key;
}

@property (nonatomic, copy, readwrite) NSString *access_key;
@property (nonatomic, copy, readwrite) NSString *secret_key;
- (id)init:(NSString*)ak secret_key:(NSString*)sk;

@end
