//
//  AWSAccount.h
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/18/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AWSAccount : NSObject {
	NSString* name;
	NSString* access_key;
	NSString* secret_key;
}

@property (nonatomic, assign, readwrite) NSString *name;
@property (nonatomic, assign, readwrite) NSString *access_key;
@property (nonatomic, assign, readwrite) NSString *secret_key;

- (id)initWithName:(NSString*)name accessKey:(NSString*)ak secretKey:(NSString*)sk;
+ (id)accountWithName:(NSString*)name_ accessKey:(NSString*)ak secretKey:(NSString*)sk;

@end
