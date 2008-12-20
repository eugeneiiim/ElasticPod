//
//  EC2DataController.h
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/21/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AWSAccount.h"
#import "EC2Instance.h"

@interface EC2DataController : NSObject {
	AWSAccount* account;
	NSDictionary* instanceData; /* reservation group name -> {instance name -> instance} */

	NSMutableDictionary* tempInstanceData;
	NSMutableData* urlreq_data;
	NSString* lastElementName;
	NSMutableDictionary* curGroupDict;
	EC2Instance* curInst;
	NSInvocation* refreshCallback;
}

@property (assign, readwrite) AWSAccount* account;
@property (nonatomic, assign, readwrite) NSDictionary* instanceData;
@property (assign, readwrite) NSMutableDictionary* tempInstanceData;
@property (assign, readwrite) NSMutableData* urlreq_data;
@property (assign, readwrite) NSString* lastElementName;
@property (nonatomic, assign, readwrite) NSMutableDictionary* curGroupDict;
@property (nonatomic, assign, readwrite) EC2Instance* curInst;
@property (nonatomic, assign, readwrite) NSInvocation* refreshCallback;

- (void)terminateInstances:(NSArray*)instances;
- (void)terminateInstanceGroup:(NSString*)grp;
- (id)initWithAccount:(AWSAccount*)account;
- (void)rebootInstances:(NSArray*)instances;
- (void)runInstances:(EC2Instance*)modelInstance n:(NSInteger)numInstances;
- (NSArray*)getInstanceGroups;
- (NSArray*)getInstancesForGroup:(NSString*)grp;
- (void)refreshInstanceData:(SEL)callback target:(id)target;
- (void)refreshInstanceData;

@end

@interface NSData (OpenSSLWrapper)

//- (NSData *)md5Digest;
- (NSData *)sha1Digest;
- (NSData *)sha1HMacWithKey:(NSString*)key;

- (NSString *)encodeBase64;
- (NSString *)encodeBase64WithNewlines: (BOOL)encodeWithNewlines;

@end
