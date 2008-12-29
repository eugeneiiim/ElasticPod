//
//  EC2DataController.m
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/21/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import "EC2DataController.h"
#import "EC2InstanceGroup.h"
#import <openssl/ssl.h>
#import <openssl/hmac.h>
#import "EC2RequestDelegate.h"

@implementation NSData (OpenSSLWrapper)

- (NSData *)sha1Digest {
	EVP_MD_CTX mdctx;
	unsigned char md_value[EVP_MAX_MD_SIZE];
	unsigned int md_len;
	EVP_DigestInit(&mdctx, EVP_sha1());
	EVP_DigestUpdate(&mdctx, [self bytes], [self length]);
	EVP_DigestFinal(&mdctx, md_value, &md_len);
	return [NSData dataWithBytes:md_value length:md_len];
}

- (NSData *)sha1HMacWithKey:(NSString *)key {
	HMAC_CTX mdctx;
	unsigned char md_value[EVP_MAX_MD_SIZE];
	unsigned int md_len;
	const char* k = [key cStringUsingEncoding:NSUTF8StringEncoding];
	const unsigned char *data = [self bytes];
	int len = [self length];
	
	HMAC_CTX_init(&mdctx);
	HMAC_Init(&mdctx,k,strlen(k),EVP_sha1());
	HMAC_Update(&mdctx,data, len);
	HMAC_Final(&mdctx, md_value, &md_len);
	HMAC_CTX_cleanup(&mdctx);
	return [NSData dataWithBytes:md_value length:md_len];
}

- (NSString *) encodeBase64WithNewlines:(BOOL) encodeWithNewlines {
    BIO *mem = BIO_new(BIO_s_mem());
	BIO *b64 = BIO_new(BIO_f_base64());
    if (!encodeWithNewlines)
        BIO_set_flags(b64, BIO_FLAGS_BASE64_NO_NL);
    mem = BIO_push(b64, mem);
	
	BIO_write(mem, [self bytes], [self length]);
    BIO_flush(mem);
	
	char *base64Pointer;
    long base64Length = BIO_get_mem_data(mem, &base64Pointer);
	
	NSString *base64String = [NSString stringWithCString:base64Pointer
												  length:base64Length];
	
	BIO_free_all(mem);
    return base64String;
}

- (NSString *)encodeBase64 {
    return [self encodeBase64WithNewlines:NO];
}
@end

@implementation EC2DataController

@synthesize account, instanceData, rootViewController, instDataState, availabilityZones, keyNames;

- (id)initWithAccount:(AWSAccount*)acct rootViewController:(RootViewController*)rvc {
	self.instanceData = nil; //[[NSDictionary alloc] init];
	self.availabilityZones = nil;
	self.keyNames = nil;
	self.account = acct;
	self.rootViewController = rvc;
	//self.requestLock = [[NSRecursiveLock alloc] init];
	//self.currentReqType = NO_REQUEST;
	self.instDataState = INSTANCE_DATA_NOT_READY;
	//[self refreshInstanceData];
	return self;
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
	[args setValue:[modelInstance getProperty:@"keyName"] forKey:@"KeyName"];
	[args setValue:numinsts_str forKey:@"MaxCount"];
	[args setValue:numinsts_str forKey:@"MinCount"];
	[args setValue:[modelInstance getProperty:@"availabilityZone"] forKey:@"Placement.AvailabilityZone"];

	//[self executeRequest:@"RunInstances" args:args];
}

- (NSArray*)getInstanceGroups {
	if (instanceData == nil) {
		NSLog(@"instance data is nil!");
		return [[[NSArray alloc] init] autorelease];
	}

	return [instanceData allKeys];
}

- (NSArray*)getInstancesForGroup:(NSString*)grp {
	return [[instanceData valueForKey:grp] allValues];
}

- (NSString*)generateSignature:(NSString*)req secret:(NSString*)secret {
	NSString* canonical = [req stringByReplacingOccurrencesOfString:@"&" withString:@""];
	NSString* stringToSign = [canonical stringByReplacingOccurrencesOfString:@"=" withString:@""];
	
	NSLog(stringToSign);
	
	NSString* sig = [[[stringToSign dataUsingEncoding:NSUTF8StringEncoding] sha1HMacWithKey:secret] encodeBase64];
	sig = [sig stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
	NSLog(sig);
	
	return sig;
}

- (void)executeRequest:(NSString*)action args:(NSDictionary*)args {
	//[self.requestLock lock]; // prevent simultaneous requests.
	[rootViewController showLoadingScreen];

	if ([action compare:@"DescribeInstances"] == NSOrderedSame) {
//		self.currentReqType = DESCRIBE_INSTANCES;
	} else if ([action compare:@"RebootInstances"] == NSOrderedSame) {
//		self.currentReqType = REBOOT_INSTANCES;
	} else if ([action compare:@"TerminateInstances"] == NSOrderedSame) {
//		self.currentReqType = TERMINATE_INSTANCES;
	} else if ([action compare:@"DescribeAvailabilityZones"] == NSOrderedSame) {		
//		self.currentReqType = DESCRIBE_AVAILABILITY_ZONES;
	} else if ([action compare:@"DescribeKeyPairs"] == NSOrderedSame) {
//		self.currentReqType = DESCRIBE_KEY_PAIRS;
	} else {
		NSLog(@"ERROR invalid request type!!! %@", action);
		[rootViewController hideLoadingScreen];
		currentReqType = NO_REQUEST;
		//[requestLock unlock];
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

	NSMutableString* argsStr = [[NSMutableString alloc] initWithString:@""];
	for (NSString* k in [args allKeys]) {
		[argsStr appendFormat:@"&%@=%@", k, [args valueForKey:k]];
	}

	NSString* req1 = [NSString stringWithFormat:@"Action=%@&AWSAccessKeyId=%@%@&SignatureVersion=1&Timestamp=%@&Version=2008-05-05", action, account.access_key, argsStr, timestamp];
	NSString* sig = [self generateSignature:req1 secret:account.secret_key];
	NSString* url = [[NSString alloc] initWithFormat:@"https://ec2.amazonaws.com/?%@&Signature=%@", req1, sig];

	NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
									 timeoutInterval:20.0];
	EC2RequestDelegate* req_delegate = [[[EC2RequestDelegate alloc] init] autorelease];
	NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:req delegate:req_delegate];
	if (!theConnection) {
		self.instDataState = INSTANCE_DATA_NOT_READY;

		//[urlreq_data release];
		[rootViewController hideLoadingScreen];
		currentReqType = NO_REQUEST;
	//	[requestLock unlock];

		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Connection failed.  Check your Internet connection."
													   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
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

@end
