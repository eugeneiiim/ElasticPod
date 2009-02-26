//
//  EC2DataController.m
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/21/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import "EC2DataController.h"
#import "EC2InstanceGroup.h"
#import "EC2RequestDelegate.h"

#import "hmac.h"
#import "base64.h"

@implementation NSData (OpenSSLWrapper)

- (NSData *)sha1HMacWithKey:(NSString *)key {
	char md_value[64];
	const char* k = [key cStringUsingEncoding:NSUTF8StringEncoding];
	const char *data = [self bytes];
	int len = [self length];

	hmac_sha1(k, strlen(k), data, len, md_value);

	return [NSData dataWithBytes:md_value length:20];
}

- (NSString*) encodeBase64 {
	char* result;
	int len = base64_encode_alloc([self bytes], [self length], &result);
	return [NSString stringWithCString:result length:len];
}

@end

@implementation EC2DataController

@synthesize account, instanceData, rootViewController, instDataState, availabilityZones, keyNames,
	instanceTypes, errorDisplayed, securityGroups, orderedGroups;

- (id)initWithAccount:(AWSAccount*)acct rootViewController:(RootViewController*)rvc {
	if ([super init]) {
		self.instanceData = nil; //[[NSDictionary alloc] init];
		self.availabilityZones = nil;
		self.keyNames = nil;
		self.account = acct;
		self.rootViewController = rvc;
		self.instDataState = INSTANCE_DATA_NOT_READY;
		self.instanceTypes = [NSArray arrayWithObjects:@"m1.small",@"m1.large",@"m1.xlarge",@"c1.medium",@"c1.xlarge",nil];
		self.errorDisplayed = FALSE;
		self.securityGroups = nil;
		self.orderedGroups = nil;
	}
	return self;
}

- (void)dealloc {
	[self.instanceTypes release];
    [super dealloc];
}

- (void)terminateInstances:(NSArray*)instances {
	NSInteger count = 1;
	NSMutableDictionary* args = [[NSMutableDictionary alloc] init];
	for (EC2Instance* inst in instances) {
		NSString* key = [NSString stringWithFormat:@"InstanceId.%d", count];
		[args setValue:[inst getProperty:@"instanceId"] forKey:key];
		count++;
	}

	[self executeRequest:@"TerminateInstances" args:args];
}

- (void)terminateInstanceGroup:(NSString*)grp {
	[self terminateInstances:[self getInstancesForGroup:grp]];
}

- (void)rebootInstances:(NSArray*)instances {
	NSInteger count = 1;
	NSMutableDictionary* args = [[NSMutableDictionary alloc] init];
	for (EC2Instance* inst in instances) {
		NSString* key = [NSString stringWithFormat:@"InstanceId.%d", count];
		[args setValue:[inst getProperty:@"instanceId"] forKey:key];
		count++;
	}

	[self executeRequest:@"RebootInstances" args:args];
}

- (void)runInstances:(EC2Instance*)modelInstance n:(NSInteger)numInstances {
	NSString* numinsts_str = [NSString stringWithFormat:@"%d", numInstances];

	NSMutableDictionary* args = [[NSMutableDictionary alloc] init];
	[args setValue:[modelInstance getProperty:@"imageId"] forKey:@"ImageId"];
	[args setValue:[modelInstance getProperty:@"instanceType"] forKey:@"InstanceType"];

	if ([modelInstance getProperty:@"keyName"]) {
		[args setValue:[modelInstance getProperty:@"keyName"] forKey:@"KeyName"];
	}
	
	[args setValue:numinsts_str forKey:@"MaxCount"];
	[args setValue:numinsts_str forKey:@"MinCount"];
	
	if ([modelInstance getProperty:@"availabilityZone"]) {
		[args setValue:[modelInstance getProperty:@"availabilityZone"] forKey:@"Placement.AvailabilityZone"];
	}

	if ([modelInstance getProperty:@"kernelId"]) {
		[args setValue:[modelInstance getProperty:@"kernelId"] forKey:@"KernelId"];
	}
	if ([modelInstance getProperty:@"ramdiskId"]) {
		[args setValue:[modelInstance getProperty:@"ramdiskId"] forKey:@"RamdiskId"];
	}

	NSInteger count = 1;
	for (NSString* secgroup in modelInstance.securityGroups) {
		[args setValue:secgroup forKey:[NSString stringWithFormat:@"SecurityGroup.%d",count]];
		count++;
	}

	[self executeRequest:@"RunInstances" args:args];
}

- (NSArray*)getInstanceGroups {
	if (instanceData == nil) {
		//NSLog(@"instance data is nil!");
		return [[[NSArray alloc] init] autorelease];
	}

	return self.orderedGroups;
}

- (NSArray*)getInstancesForGroup:(NSString*)grp {
	return [[instanceData valueForKey:grp] allValues];
}

- (NSString*)generateSignature:(NSString*)req secret:(NSString*)secret {
	NSString* canonical = [req stringByReplacingOccurrencesOfString:@"&" withString:@""];
	NSString* stringToSign = [canonical stringByReplacingOccurrencesOfString:@"=" withString:@""];
	//NSLog(stringToSign);
	
	NSString* sig = [[[stringToSign dataUsingEncoding:NSUTF8StringEncoding] sha1HMacWithKey:secret] encodeBase64];
	sig = [sig stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];

	return sig;
}

NSInteger strSort(id s1, id s2, void *context) {
	return [s1 compare:s2];
}

- (void)executeRequest:(NSString*)action args:(NSDictionary*)args {
	[rootViewController showLoadingScreen];

	RequestType req_type;
	if ([action compare:@"DescribeInstances"] == NSOrderedSame) {
		req_type = DESCRIBE_INSTANCES;
	} else if ([action compare:@"RebootInstances"] == NSOrderedSame) {
		req_type = REBOOT_INSTANCES;
	} else if ([action compare:@"TerminateInstances"] == NSOrderedSame) {
		req_type = TERMINATE_INSTANCES;
	} else if ([action compare:@"DescribeAvailabilityZones"] == NSOrderedSame) {		
		req_type = DESCRIBE_AVAILABILITY_ZONES;
	} else if ([action compare:@"DescribeKeyPairs"] == NSOrderedSame) {
		req_type = DESCRIBE_KEY_PAIRS;
	} else if ([action compare:@"RunInstances"] == NSOrderedSame) {
		req_type = RUN_INSTANCES;
	} else if ([action compare:@"DescribeSecurityGroups"] == NSOrderedSame) {
		req_type = DESCRIBE_SECURITY_GROUPS;
	} else {
		NSLog(@"ERROR invalid request type!!! %@", action);
		[rootViewController hideLoadingScreen];
		return;
	}

	NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
	[formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
	NSDate* now = [NSDate date];
	[formatter setDateFormat:@"YYYY-MM-dd"];
	NSString* timestamp_date = [formatter stringFromDate:now];
	[formatter setDateFormat:@"HH:mm:ss"];
	NSString* timestamp_time = [formatter stringFromDate:now];
	NSString* timestamp = [NSString stringWithFormat:@"%@T%@Z", timestamp_date, timestamp_time];
	[formatter release];

	NSMutableString* argsStr = [NSMutableString stringWithString:@""];
	NSArray* sorted_keys = [[args allKeys] sortedArrayUsingFunction:strSort context:nil];
	for (NSString* k in sorted_keys) {
		[argsStr appendFormat:@"&%@=%@", k, [args valueForKey:k]];
	}

	NSString* req1 = [NSString stringWithFormat:@"Action=%@&AWSAccessKeyId=%@%@&SignatureVersion=1&Timestamp=%@&Version=2008-05-05", action, account.access_key, argsStr, timestamp];
	NSString* sig = [self generateSignature:req1 secret:account.secret_key];
	NSString* url = [NSString stringWithFormat:@"https://ec2.amazonaws.com/?%@&Signature=%@", req1, sig];

	NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
									 timeoutInterval:20.0];
	EC2RequestDelegate* req_delegate = [[EC2RequestDelegate alloc] init:self requestType:req_type];
	
	NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:req delegate:req_delegate];
	if (!theConnection) {
		self.instDataState = INSTANCE_DATA_NOT_READY;
		[self.rootViewController hideLoadingScreen];
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Connection failed.  Check your Internet connection."
													   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else {
		[req_delegate release];
	}
}

- (void)refreshInstanceData {
	[self executeRequest:@"DescribeInstances" args:[[[NSDictionary alloc] init] autorelease]];
}

- (EC2Instance*)getInstance:(NSString*)group instanceId:(NSString*)inst_id {
	return [[instanceData valueForKey:group] valueForKey:inst_id];
}

- (NSString*)getInstanceGroupAtIndex:(NSInteger)index {
	NSArray* instanceGroups = [self getInstanceGroups];
	if (index >= [instanceGroups count]) {
		NSLog(@"ERROR index outside of range of instance groups...");
		return nil;
	} else {
		return [instanceGroups objectAtIndex:index];
	}
}

- (EC2Instance*)getInstanceAtIndex:(NSInteger)index group:(NSString*)grp {
	NSDictionary* instances = [self.instanceData valueForKey:grp];
	if (index >= [[instances allKeys] count]) {
		NSLog(@"ERROR no instance at this index.");
		return nil;
	} else {
		NSString* instanceId = [[instances allKeys] objectAtIndex:index];
		return [instances valueForKey:instanceId];
	}
}

- (void)setInstanceData:(NSDictionary *)newdict {
	if (instanceData != newdict) {
		[instanceData release];
		instanceData = [newdict mutableCopy];
	}
}

- (void)setOrderedGroups:(NSArray*)newarr {
	if (orderedGroups != newarr) {
		[orderedGroups release];
		orderedGroups = [newarr mutableCopy];
	}
}

- (void)setAvailabilityZones:(NSArray*)newarr {
	if (availabilityZones != newarr) {
		[availabilityZones release];
		availabilityZones = [newarr mutableCopy];
	}
}

- (void)refreshAvailabilityZones {
	[self executeRequest:@"DescribeAvailabilityZones" args:[[[NSDictionary alloc] init] autorelease]];
}

- (NSArray*)getAvailabilityZones {
	if (self.availabilityZones == nil) {
		return [[[NSArray alloc] init] autorelease];
	} else {
		return self.availabilityZones;
	}
}

- (NSArray*)getKeyNames {
	if (self.keyNames == nil) {
		return [[[NSArray alloc] init] autorelease];
	} else {
		return self.keyNames;
	}
}

- (void)refreshKeyNames {
	[self executeRequest:@"DescribeKeyPairs" args:[[[NSDictionary alloc] init] autorelease]];
}

- (void)setKeyNames:(NSArray*)newarr {
	if (keyNames != newarr) {
		[keyNames release];
		keyNames = [newarr mutableCopy];
	}
}

- (NSArray*)getSecurityGroups {
	if (self.securityGroups == nil) {
		return [[[NSArray alloc] init] autorelease];
	} else {
		return self.securityGroups;
	}
}

- (void)refreshSecurityGroups {
	[self executeRequest:@"DescribeSecurityGroups" args:[[[NSDictionary alloc] init] autorelease]];
}

- (void)setSecurityGroups:(NSArray*)newarr {
	if (securityGroups != newarr) {
		[securityGroups release];
		securityGroups = [newarr mutableCopy];
	}
}

@end
