//
//  EC2RequestDelegate.h
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/28/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EC2DataController.h"

@interface EC2RequestDelegate : NSObject <UIAlertViewDelegate> {
	EC2DataController* ec2Controller;
	NSMutableData* urlreq_data;
	RequestType reqType;

	NSMutableDictionary* curGroupDict;
	EC2Instance* curInst;
	NSMutableArray* curSecurityGroups;

	NSMutableDictionary* tempInstanceData;
	NSMutableArray* tempAvailabilityZones;
	NSMutableArray* tempKeyNames;
	NSMutableArray* tempSecurityGroups;

	NSString* lastLastElementName;
	NSString* lastElementName;
	NSString* curAvailZone;

	NSMutableArray* tempOrderedGroups;
	
	NSString* targetInst;
	NSString* targetInstGroup;
}

@property (nonatomic, readwrite, assign) EC2DataController* ec2Controller;
@property (nonatomic, readwrite, assign) NSMutableData* urlreq_data;
@property (nonatomic, readwrite, assign) RequestType reqType;
@property (nonatomic, assign, readwrite) NSMutableDictionary* curGroupDict;
@property (nonatomic, assign, readwrite) EC2Instance* curInst;
@property (nonatomic, assign, readwrite) NSMutableDictionary* tempInstanceData;
@property (nonatomic, assign, readwrite) NSMutableArray* tempAvailabilityZones;
@property (nonatomic, assign, readwrite) NSMutableArray* tempKeyNames;
@property (nonatomic, assign, readwrite) NSMutableArray* tempSecurityGroups;
@property (nonatomic, assign, readwrite) NSString* lastElementName;
@property (nonatomic, assign, readwrite) NSString* lastLastElementName;
@property (nonatomic, assign, readwrite) NSString* curAvailZone;
@property (nonatomic, assign, readwrite) NSMutableArray* curSecurityGroups;
@property (nonatomic, assign, readwrite) NSMutableArray* tempOrderedGroups;
@property (nonatomic, assign, readwrite) NSString* targetInst;
@property (nonatomic, assign, readwrite) NSString* targetInstGroup;

- (EC2RequestDelegate*)init:(EC2DataController*)ec2ctrl requestType:(RequestType)type;
- (EC2RequestDelegate*)init2:(EC2DataController*)ec2ctrl requestType:(RequestType)type
				  instanceId:(NSString*)instId groupId:(NSString*)groupId;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
