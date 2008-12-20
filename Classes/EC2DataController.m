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

- (NSString *) encodeBase64WithNewlines:(BOOL) encodeWithNewlines
{
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

@synthesize account, instanceData, tempInstanceData, urlreq_data, curGroupDict, curInst, lastElementName, refreshCallback;

- (id)initWithAccount:(AWSAccount*)acct {
	refreshCallback = [[NSInvocation alloc] init];
	instanceData = nil; //[[NSDictionary alloc] init];
	self.account = acct;
	//[self refreshInstanceData];
	return self;
}

- (void)terminateInstances:(NSArray*)instances {
	printf("TODO terminate instances");
}

- (void)terminateInstanceGroup:(NSString*)grp {
	printf("TODO terminate instance group");
}

- (void)rebootInstances:(NSArray*)instances {
	printf("TODO reboot instances");
}

- (void)runInstances:(EC2Instance*)modelInstance n:(NSInteger)numInstances {
	printf("TODO launch some instances");
}

- (NSArray*)getInstanceGroups {
	if (instanceData == nil) {
		NSLog(@"instance data is nil!");
		[self refreshInstanceData:nil target:self];
		return [[NSArray alloc] init];
	}

	//[self refreshInstanceData];

	return [instanceData allKeys];
}

- (NSArray*)getInstancesForGroup:(NSString*)grp {
	return [[instanceData valueForKey:grp] allValues];
}

- (NSString*)generateSignature:(NSString*)req secret:(NSString*)secret {
	NSString* canonical = [req stringByReplacingOccurrencesOfString:@"&" withString:@""];
	canonical = [canonical stringByReplacingOccurrencesOfString:@"=" withString:@""];
	NSLog(canonical);
	
	NSString* stringToSign = canonical; //[NSString stringWithFormat:@"GET\nec2.amazonaws.com\n/\n%@", canonical];
	NSLog(@"String to sign: %@", stringToSign);

	NSString* sign = [[[stringToSign dataUsingEncoding:NSUTF8StringEncoding] sha1HMacWithKey:secret] encodeBase64];
	NSLog(@"Signature is: %@", sign);
	return sign;
}

- (void)refreshInstanceData {
	urlreq_data = [[NSMutableData alloc] init];

	NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
	[formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
	NSDate* now = [NSDate date];
	[formatter setDateFormat:@"YYYY-MM-dd"];
	NSString* timestamp_date = [formatter stringFromDate:now];
	[formatter setDateFormat:@"HH:mm:ss"];
	NSString* timestamp_time = [formatter stringFromDate:now];
	NSString* timestamp = [NSString stringWithFormat:@"%@T%@Z", timestamp_date, timestamp_time];
	NSLog(timestamp);	

	NSString* req1 = [NSString stringWithFormat:@"Action=DescribeInstances&AWSAccessKeyId=%@&SignatureVersion=1&Timestamp=%@&Version=2008-05-05", [account access_key], timestamp];
	NSString* sig = [self generateSignature:req1 secret:[account secret_key]];

	NSString* url = [[NSString alloc] initWithFormat:@"https://ec2.amazonaws.com/?%@&Signature=%@", req1, sig];
	NSLog(url);
	//url = @"http://localhost/~emarinel/x.xml";

	NSLog(@"making request...");
	NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
										 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
									 timeoutInterval:60.0];
	NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
	if (theConnection) {
		printf("connection true\n");
		//receivedData=[[NSMutableData data] retain];
	} else {
		printf("connection false\n");
		// inform the user that the download could not be made
	}
}

- (void)refreshInstanceData:(SEL)callback target:(id)target {
		//NSMethodSignature* sign = [[target class] instanceMethodSignatureForSelector:callback];
		//refreshCallback = [NSInvocation invocationWithMethodSignature:sign];
		//[refreshCallback setSelector:callback];
		//[refreshCallback setTarget:target];
	
	[self refreshInstanceData];
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

    // inform the user
	NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription],
		[[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[connection release];
	
	curGroupDict = nil;
	curInst = nil;
	tempInstanceData = [[NSMutableDictionary alloc] init];

	NSLog([[NSString alloc] initWithData:urlreq_data encoding:NSASCIIStringEncoding]);
	
	NSXMLParser* x = [[NSXMLParser alloc] initWithData:urlreq_data];
	[x setDelegate:self];
	[x parse];

	[urlreq_data release];
}

// Parser event handlers
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	lastElementName = elementName;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([elementName compare:@"instancesSet"] == NSOrderedSame) {
		// End of this reservation group.
		curGroupDict = nil;
	}

	if ([elementName compare:@"item"] == NSOrderedSame) {
		// End of this instance.
		curInst = nil;
	}
}

- (void)parser:(NSXMLParser*)parser foundCharacters:(NSString*)string {
	string = [string stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" \n"]];
	if (string == nil || [string length] == 0) {
		return;
	}

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
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	self.instanceData = [NSDictionary dictionaryWithDictionary:tempInstanceData];
	[tempInstanceData release];

	// Refresh the view.
	printf("calling refresh callback!\n");
	if ([refreshCallback selector] != nil) {
		printf("YES calling refresh callback!\n");
		[refreshCallback invoke];
	}
}

- (void)setInstanceData:(NSDictionary *)newdict {
	if (instanceData != newdict) {
		[instanceData release];
		instanceData = [newdict mutableCopy];
	}
}

@end
