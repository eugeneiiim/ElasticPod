//
//  EC2RequestDelegate.m
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/28/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import "EC2RequestDelegate.h"
#import "EC2DataController.h"

@implementation EC2RequestDelegate

@synthesize ec2Controller, urlreq_data, reqType, curGroupDict, curInst, tempInstanceData, tempAvailabilityZones,
	tempKeyNames, curAvailZone, lastElementName, curSecurityGroups;

- (EC2RequestDelegate*)init:(EC2DataController*)ec2ctrl requestType:(RequestType)type {
	if ([self init]) {
		self.ec2Controller = ec2ctrl;
		self.reqType = type;
		self.urlreq_data = [[NSMutableData alloc] init];
	}
	return self;
}

// Connection event handlers.
/*
 - (void)connection:(NSURLConnection*)conn didReceiveResponse:(NSURLResponse*)response {
 }*/

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[self.urlreq_data appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	// release the connection, and the data object
	[connection release];
	[self.urlreq_data release];

	if (self.reqType == DESCRIBE_INSTANCES) {
		self.ec2Controller.instDataState = INSTANCE_DATA_NOT_READY;
	}

	// inform the user
	NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription],
		  [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
	
	NSString* msg = @"Connection failed.  Check your Internet connection.";
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:msg
												   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];

	[self.ec2Controller.rootViewController hideLoadingScreen];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[connection release];

	if (self.reqType == DESCRIBE_INSTANCES)  {
		self.curGroupDict = nil;
		self.curInst = nil;
		self.curSecurityGroups = nil;
	}

	if (self.reqType == DESCRIBE_INSTANCES) {
		self.tempInstanceData = [[NSMutableDictionary alloc] init];
	} else if (self.reqType == DESCRIBE_AVAILABILITY_ZONES) {
		self.tempAvailabilityZones = [[NSMutableArray alloc] init];
	} else if (self.reqType == DESCRIBE_KEY_PAIRS) {
		self.tempKeyNames = [[NSMutableArray alloc] init];
	}

	NSLog([[NSString alloc] initWithData:self.urlreq_data encoding:NSASCIIStringEncoding]);

	NSXMLParser* x = [[NSXMLParser alloc] initWithData:self.urlreq_data];
	[x setDelegate:self];
	[x parse];

	[self.urlreq_data release];
}

// Parser event handlers
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
	qualifiedName:(NSString *)qualifiedName	attributes:(NSDictionary *)attributeDict {
	if (self.reqType == DESCRIBE_INSTANCES && [elementName compare:@"DescribeInstancesResponse"] == NSOrderedSame) {
		self.ec2Controller.instDataState = INSTANCE_DATA_READY;
	}

	self.lastElementName = elementName;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if (self.reqType == DESCRIBE_INSTANCES) {
		if ([elementName compare:@"instancesSet"] == NSOrderedSame) {
			// End of this reservation group.
			self.curGroupDict = nil;
		}
		if ([elementName compare:@"item"] == NSOrderedSame) {
			// End of this instance.
			self.curInst = nil;
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

		if (self.reqType == DESCRIBE_INSTANCES) {
			[self.tempInstanceData release];
			self.tempInstanceData = nil; // indicate that this new data should not be used.
		} else if (self.reqType == DESCRIBE_AVAILABILITY_ZONES) {
			[self.tempAvailabilityZones release];
			self.tempAvailabilityZones = nil;
		} else if (self.reqType == DESCRIBE_KEY_PAIRS) {
			[self.tempKeyNames release];
			self.tempKeyNames = nil;
		}

		if ([string compare:@"SignatureDoesNotMatch"] == NSOrderedSame) {
			NSString* msg = [NSString stringWithFormat:@"Request failed for account \"%@\".  Check your secret key.", self.ec2Controller.account.name];
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Invalid Request Signature" message:msg
														   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];

			self.ec2Controller.instDataState = INSTANCE_DATA_FAILED;
			return;
		} else if ([string compare:@"InvalidClientTokenId"] == NSOrderedSame) {
			NSString* msg = [NSString stringWithFormat:@"Request failed for account \"%@\".  Check your access key.", self.ec2Controller.account.name];
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Invalid Access Key" message:msg
														   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
			
			self.ec2Controller.instDataState = INSTANCE_DATA_FAILED;
			return;
		}
		// TODO check for other errors
	}

	if (self.reqType == DESCRIBE_INSTANCES) {
		if ([self.lastElementName compare:@"reservationId"] == NSOrderedSame) {
			self.curGroupDict = [[NSMutableDictionary alloc] init];
			[self.tempInstanceData setValue:self.curGroupDict forKey:[string copy]];
			//self.curSecurityGroups = [[NSMutableArray alloc] init];
		} else if ([self.lastElementName compare:@"instanceId"] == NSOrderedSame) {
			self.curInst = [[EC2Instance alloc] init];
			[self.curGroupDict setValue:self.curInst forKey:[string copy]];
			//self.curInst.securityGroups = [self.curSecurityGroups copy];
		} else if ([self.lastElementName compare:@"groupId"] == NSOrderedSame) {
			//[self.curSecurityGroups addObject:[string copy]];
		}

		if (self.curInst != nil) {
			[self.curInst addProperty:[self.lastElementName copy] value:[string copy]];
		}
	} else if (self.reqType == DESCRIBE_AVAILABILITY_ZONES) {
		if ([lastElementName compare:@"zoneName"] == NSOrderedSame) {
			self.curAvailZone = [string copy];
		} else if ([lastElementName compare:@"zoneState"] == NSOrderedSame) {
			if ([string compare:@"available"] == NSOrderedSame) {
				[self.tempAvailabilityZones addObject:[curAvailZone copy]];
			}
		}
	} else if (self.reqType == DESCRIBE_KEY_PAIRS) {
		if ([self.lastElementName compare:@"keyName"] == NSOrderedSame) {
			[self.tempKeyNames addObject:[string copy]];
		}
	}
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	if (self.reqType == DESCRIBE_INSTANCES && self.tempInstanceData != nil) {
		self.ec2Controller.instanceData = [NSDictionary dictionaryWithDictionary:self.tempInstanceData];
		[self.tempInstanceData release];
		self.tempInstanceData = nil;
	} else if (self.reqType == DESCRIBE_AVAILABILITY_ZONES && self.tempAvailabilityZones != nil) {
		self.ec2Controller.availabilityZones = [NSArray arrayWithArray:self.tempAvailabilityZones];
		[self.tempAvailabilityZones release];
		self.tempAvailabilityZones = nil;
	} else if (self.reqType == DESCRIBE_KEY_PAIRS && self.tempKeyNames != nil) {
		self.ec2Controller.keyNames = [NSArray arrayWithArray:self.tempKeyNames];
		[self.tempKeyNames release];
		self.tempKeyNames = nil;
	}
	
	// Refresh the view.
	[self.ec2Controller.rootViewController.navigationController.topViewController refreshEC2Callback];
	
	[self.ec2Controller.rootViewController hideLoadingScreen];
	self.reqType = NO_REQUEST;
}

@end
