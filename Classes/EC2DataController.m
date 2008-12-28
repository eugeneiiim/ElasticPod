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

@implementation NSData (OpenSSLWrapper)

/*
- (NSData *)md5Digest
{
	EVP_MD_CTX mdctx;
	unsigned char md_value[EVP_MAX_MD_SIZE];
	unsigned int md_len;
	EVP_DigestInit(&mdctx, EVP_md5());
	EVP_DigestUpdate(&mdctx, [self bytes], [self length]);
	EVP_DigestFinal(&mdctx, md_value, &md_len);
	return [NSData dataWithBytes:md_value length:md_len];
}*/

- (NSData *)sha1Digest
{
	EVP_MD_CTX mdctx;
	unsigned char md_value[EVP_MAX_MD_SIZE];
	unsigned int md_len;
	EVP_DigestInit(&mdctx, EVP_sha1());
	EVP_DigestUpdate(&mdctx, [self bytes], [self length]);
	EVP_DigestFinal(&mdctx, md_value, &md_len);
	return [NSData dataWithBytes:md_value length:md_len];
}

- (NSData *)sha1HMacWithKey:(NSString *)key
{
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

- (NSString *)encodeBase64
{
    return [self encodeBase64WithNewlines:NO];
}
@end

@implementation EC2DataController

@synthesize account, instanceData, tempInstanceData, urlreq_data, curGroupDict, curInst, lastElementName, rootViewController, currentReqType, requestLock, instDataState, availabilityZones, tempAvailabilityZones, curAvailZone;

- (id)initWithAccount:(AWSAccount*)acct rootViewController:(RootViewController*)rvc {
	self.instanceData = nil; //[[NSDictionary alloc] init];
	self.availabilityZones = nil;
	self.account = acct;
	self.rootViewController = rvc;
	self.requestLock = [[NSRecursiveLock alloc] init];
	self.currentReqType = NO_REQUEST;
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
	printf("TODO launch some instances");
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
	[self.requestLock lock]; // prevent simultaneous requests.
	[rootViewController showLoadingScreen];

	if ([action compare:@"DescribeInstances"] == NSOrderedSame) {
		currentReqType = DESCRIBE_INSTANCES;
	} else if ([action compare:@"RebootInstances"] == NSOrderedSame) {
		currentReqType = REBOOT_INSTANCES;
	} else if ([action compare:@"TerminateInstances"] == NSOrderedSame) {
		currentReqType = TERMINATE_INSTANCES;
	} else if ([action compare:@"DescribeAvailabilityZones"] == NSOrderedSame) {		
		currentReqType = DESCRIBE_AVAILABILITY_ZONES;
	} else {
		NSLog(@"ERROR invalid request type!!! %@", action);
		[rootViewController hideLoadingScreen];
		currentReqType = NO_REQUEST;
		[requestLock unlock];
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

	NSLog(@"making request...");
	NSLog(url);

	urlreq_data = [[NSMutableData alloc] init];
	NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
										 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
									 timeoutInterval:20.0];
	NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
	if (!theConnection) {
		self.instDataState = INSTANCE_DATA_NOT_READY;

		[urlreq_data release];
		[rootViewController hideLoadingScreen];
		currentReqType = NO_REQUEST;
		[requestLock unlock];

		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Connection failed.  Check your Internet connection."
													   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (void)refreshInstanceData {
	[self executeRequest:@"DescribeInstances" args:[[[NSDictionary alloc] init] autorelease]];
}

// Connection event handlers.
/*
- (void)connection:(NSURLConnection*)conn didReceiveResponse:(NSURLResponse*)response {
}*/

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[urlreq_data appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	// release the connection, and the data object
	[connection release];
	[urlreq_data release];

	if (currentReqType == DESCRIBE_INSTANCES) {
		self.instDataState = INSTANCE_DATA_NOT_READY;
	}

    // inform the user
	NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription],
		[[error userInfo] objectForKey:NSErrorFailingURLStringKey]);

	NSString* msg = @"Connection failed.  Check your Internet connection.";
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:msg
												   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];

	[rootViewController hideLoadingScreen];
	self.currentReqType = NO_REQUEST;
	[requestLock unlock];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[connection release];

	if (self.currentReqType == DESCRIBE_INSTANCES)  {
		curGroupDict = nil;
		curInst = nil;
	}

	if (currentReqType == DESCRIBE_INSTANCES) {
		self.tempInstanceData = [[NSMutableDictionary alloc] init];
	} else if (currentReqType == DESCRIBE_AVAILABILITY_ZONES) {
		self.tempAvailabilityZones = [[NSMutableArray alloc] init];
	}

	NSLog([[NSString alloc] initWithData:urlreq_data encoding:NSASCIIStringEncoding]);
	
	NSXMLParser* x = [[NSXMLParser alloc] initWithData:urlreq_data];
	[x setDelegate:self];
	[x parse];

	[urlreq_data release];
}

// Parser event handlers
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if (self.currentReqType == DESCRIBE_INSTANCES && [elementName compare:@"DescribeInstancesResponse"] == NSOrderedSame) {
		self.instDataState = INSTANCE_DATA_READY;
	}

	self.lastElementName = elementName;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if (currentReqType == DESCRIBE_INSTANCES) {
		if ([elementName compare:@"instancesSet"] == NSOrderedSame) {
			// End of this reservation group.
			curGroupDict = nil;
		}

		if ([elementName compare:@"item"] == NSOrderedSame) {
			// End of this instance.
			curInst = nil;
		}
	}
}

- (void)parser:(NSXMLParser*)parser foundCharacters:(NSString*)string {
	string = [string stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" \n"]];
	if (string == nil || [string length] == 0) {
		return;
	}

	if ([lastElementName compare:@"Code"] == NSOrderedSame) {
		// This is an error -- todo make sure Code isn't used for other stuff.
		
		if (self.currentReqType == DESCRIBE_INSTANCES) {
			[self.tempInstanceData release];
			self.tempInstanceData = nil; // indicate that this new data should not be used.
		} else if (self.currentReqType == DESCRIBE_AVAILABILITY_ZONES) {
			[self.tempAvailabilityZones release];
			self.tempAvailabilityZones = nil;
		}
		
		if ([string compare:@"SignatureDoesNotMatch"] == NSOrderedSame) {
			NSString* msg = [NSString stringWithFormat:@"Request failed for account \"%@\".  Check your secret key.", self.account.name];
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Invalid Request Signature" message:msg
														   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
			
			self.instDataState = INSTANCE_DATA_FAILED;
			return;
		} else if ([string compare:@"InvalidClientTokenId"] == NSOrderedSame) {
			NSString* msg = [NSString stringWithFormat:@"Request failed for account \"%@\".  Check your access key.", self.account.name];
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Invalid Access Key" message:msg
														   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
			
			self.instDataState = INSTANCE_DATA_FAILED;
			return;
		}
		// TODO check for other errors
	}

	if (self.currentReqType == DESCRIBE_INSTANCES) {
		if ([lastElementName compare:@"reservationId"] == NSOrderedSame) {
			curGroupDict = [[NSMutableDictionary alloc] init];
			[tempInstanceData setValue:curGroupDict forKey:[string copy]];
		} else if ([lastElementName compare:@"instanceId"] == NSOrderedSame) {
			curInst = [[EC2Instance alloc] init];
			[curGroupDict setValue:curInst forKey:[string copy]];
		}

		if (curInst != nil) {
			[curInst addProperty:[lastElementName copy] value:[string copy]];
		}
	} else if (self.currentReqType == DESCRIBE_AVAILABILITY_ZONES) {
		if ([lastElementName compare:@"zoneName"] == NSOrderedSame) {
			curAvailZone = [string copy];
		} else if ([lastElementName compare:@"zoneState"] == NSOrderedSame) {
			if ([string compare:@"available"] == NSOrderedSame) {
				[tempAvailabilityZones addObject:curAvailZone];
			}
		}
	}
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	if (currentReqType == DESCRIBE_INSTANCES && tempInstanceData != nil) {
		self.instanceData = [NSDictionary dictionaryWithDictionary:tempInstanceData];
		[tempInstanceData release];
		tempInstanceData = nil;
	} else if (currentReqType == DESCRIBE_AVAILABILITY_ZONES && tempAvailabilityZones != nil) {
		self.availabilityZones = [NSArray arrayWithArray:tempAvailabilityZones];
		[tempAvailabilityZones release];
		tempAvailabilityZones = nil;
	}

	// Refresh the view.
	[rootViewController.navigationController.topViewController refreshEC2Callback];

	[rootViewController hideLoadingScreen];
	currentReqType = NO_REQUEST;
	[requestLock unlock];
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

@end
