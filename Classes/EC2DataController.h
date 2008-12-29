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
#import "RootViewController.h"

@class RootViewController;

typedef enum {DESCRIBE_INSTANCES, REBOOT_INSTANCES, TERMINATE_INSTANCES, NO_REQUEST, DESCRIBE_AVAILABILITY_ZONES, DESCRIBE_KEY_PAIRS} RequestType;

typedef enum {INSTANCE_DATA_READY, INSTANCE_DATA_NOT_READY, INSTANCE_DATA_FAILED} InstanceDataState;

@interface EC2DataController : NSObject {
	AWSAccount* account;
	NSDictionary* instanceData; /* reservation group name -> {instance name -> instance} */
	RootViewController* rootViewController;
	NSArray* availabilityZones;
	NSArray* keyNames;
	InstanceDataState instDataState;
}

@property (assign, readwrite) AWSAccount* account;
@property (nonatomic, assign, readwrite) NSDictionary* instanceData;
@property (nonatomic, assign, readwrite) RootViewController* rootViewController;
@property (nonatomic, assign, readwrite) InstanceDataState instDataState;
@property (nonatomic, assign, readwrite) NSArray* availabilityZones;
@property (nonatomic, assign, readwrite) NSArray* keyNames;

- (void)terminateInstances:(NSArray*)instances;
- (void)terminateInstanceGroup:(NSString*)grp;
- (id)initWithAccount:(AWSAccount*)account rootViewController:(RootViewController*)rvc;
- (void)rebootInstances:(NSArray*)instances;
- (void)runInstances:(EC2Instance*)modelInstance n:(NSInteger)numInstances;
- (NSArray*)getInstanceGroups;
- (NSArray*)getInstancesForGroup:(NSString*)grp;
- (void)refreshInstanceData;
- (void)executeRequest:(NSString*)action args:(NSDictionary*)args;
- (EC2Instance*)getInstance:(NSString*)group instanceId:(NSString*)inst_id;
- (NSString*)getInstanceGroupAtIndex:(NSInteger)index;
- (EC2Instance*)getInstanceAtIndex:(NSInteger)index group:(NSString*)grp;
- (NSArray*)getAvailabilityZones;
- (void)refreshAvailabilityZones;
- (NSArray*)getKeyNames;
- (void)refreshKeyNames;

@end

@interface NSData (OpenSSLWrapper)
//- (NSData *)md5Digest;
- (NSData *)sha1Digest;
- (NSData *)sha1HMacWithKey:(NSString*)key;
- (NSString *)encodeBase64;
- (NSString *)encodeBase64WithNewlines: (BOOL)encodeWithNewlines;
@end
