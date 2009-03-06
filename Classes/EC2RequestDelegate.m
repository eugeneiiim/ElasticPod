//
//  EC2RequestDelegate.m
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/28/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import "EC2RequestDelegate.h"
#import "EC2DataController.h"
#import "base64.h"

@implementation EC2RequestDelegate

@synthesize ec2Controller, urlreq_data, reqType, curGroupDict, curInst, tempInstanceData, tempAvailabilityZones,
	tempKeyNames, curAvailZone, lastElementName, curSecurityGroups, tempSecurityGroups, lastLastElementName,
	tempOrderedGroups, targetInst, targetInstGroup;

- (EC2RequestDelegate*)init:(EC2DataController*)ec2ctrl requestType:(RequestType)type {
	if (self = [super init]) {
		self.ec2Controller = ec2ctrl;
		self.reqType = type;
		self.urlreq_data = [[NSMutableData alloc] init];
		self.lastElementName = @"";
		self.lastLastElementName = @"";
	}
	return self;
}

- (EC2RequestDelegate*)init2:(EC2DataController*)ec2ctrl requestType:(RequestType)type
				  instanceId:(NSString*)instId groupId:(NSString*)groupId {
	if (self = [super init]) {
		self.ec2Controller = ec2ctrl;
		self.reqType = type;
		self.urlreq_data = [[NSMutableData alloc] init];
		self.lastElementName = @"";
		self.lastLastElementName = @"";

		self.targetInst = instId;
		self.targetInstGroup = groupId;
	}
	return self;
}

- (void)dealloc {
	[self.urlreq_data release];
	[super dealloc];
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
	[self.urlreq_data setData:[NSData data]];

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
	if (self.reqType == DESCRIBE_INSTANCES)  {
		self.curGroupDict = nil;
		self.curInst = nil;
		self.curSecurityGroups = nil;
	}

	if (self.reqType == DESCRIBE_INSTANCES) {
		self.tempInstanceData = [[NSMutableDictionary alloc] init];
		self.tempOrderedGroups = [[NSMutableArray alloc] init];
	} else if (self.reqType == DESCRIBE_AVAILABILITY_ZONES) {
		self.tempAvailabilityZones = [[NSMutableArray alloc] init];
	} else if (self.reqType == DESCRIBE_KEY_PAIRS) {
		self.tempKeyNames = [[NSMutableArray alloc] init];
	} else if (self.reqType == DESCRIBE_SECURITY_GROUPS) {
		self.tempSecurityGroups = [[NSMutableArray alloc] init];
	}

	//NSLog([[NSString alloc] initWithData:self.urlreq_data encoding:NSASCIIStringEncoding]);

	NSXMLParser* x = [[NSXMLParser alloc] initWithData:self.urlreq_data];
	[x setDelegate:self];
	[x parse];
}

// Parser event handlers
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
	qualifiedName:(NSString *)qualifiedName	attributes:(NSDictionary *)attributeDict {
	if (self.reqType == DESCRIBE_INSTANCES && [elementName compare:@"DescribeInstancesResponse"] == NSOrderedSame) {
		self.ec2Controller.instDataState = INSTANCE_DATA_READY;
	}

	self.lastLastElementName = self.lastElementName;
	self.lastElementName = elementName;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
	qualifiedName:(NSString *)qName {
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	self.ec2Controller.errorDisplayed = FALSE;
}

- (void)parser:(NSXMLParser*)parser foundCharacters:(NSString*)string {
	string = [string stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" \n"]];
	if (string == nil || [string length] == 0) {
		return;
	}

	if ([lastElementName compare:@"Code"] == NSOrderedSame && [lastLastElementName compare:@"Error"] == NSOrderedSame) {
		// This is an error -- todo make sure Code isn't used for other stuff.
		if (self.reqType == DESCRIBE_INSTANCES) {
			[self.tempOrderedGroups release];
			self.tempOrderedGroups = nil;
			[self.tempInstanceData release];
			self.tempInstanceData = nil; // indicate that this new data should not be used.
		} else if (self.reqType == DESCRIBE_AVAILABILITY_ZONES) {
			[self.tempAvailabilityZones release];
			self.tempAvailabilityZones = nil;
		} else if (self.reqType == DESCRIBE_KEY_PAIRS) {
			[self.tempKeyNames release];
			self.tempKeyNames = nil;
		} else if (self.reqType == DESCRIBE_SECURITY_GROUPS) {
			[self.tempSecurityGroups release];
			self.tempSecurityGroups = nil;
		}

		NSString* msg = nil;
		NSString* title = nil;
		
		if ([string compare:@"SignatureDoesNotMatch"] == NSOrderedSame) {
			msg = [NSString stringWithFormat:@"Request failed for account \"%@\".  Check your secret key.", self.ec2Controller.account.name];
			title = @"Invalid Request Signature";
			self.ec2Controller.instDataState = INSTANCE_DATA_FAILED;
		} else if ([string compare:@"InvalidClientTokenId"] == NSOrderedSame) {
			msg = [NSString stringWithFormat:@"Request failed for account \"%@\".  Check your access key.", self.ec2Controller.account.name];
			title = @"Invalid Access Key";
			self.ec2Controller.instDataState = INSTANCE_DATA_FAILED;
		} else if ([string compare:@"AuthFailure"] == NSOrderedSame) {
			msg = [NSString stringWithFormat:@"User not authorized for account \"%@\".", self.ec2Controller.account.name];
			title = @"Authorization Failure";
		} else if ([string compare:@"InstanceLimitExceeded"] == NSOrderedSame) {
			msg = [NSString stringWithFormat:@"Instance limit exceeded for account \"%@\".", self.ec2Controller.account.name];
			title = @"Instance Limit Exceeded";
		} else if ([string compare:@"InvalidAMIID.Malformed"] == NSOrderedSame) {
			msg = @"Malformed image ID.";
			title = @"Error";
		} else if ([string compare:@"InvalidAMIID.NotFound"] == NSOrderedSame) {
			msg = @"AMI ID not found.";
			title = @"Error";
		} else if ([string compare:@"InvalidAMIID.Unavailable"] == NSOrderedSame) {
			msg = @"Specified AMI is not available.";
			title = @"Error";
		} else if ([string compare:@"InternalError"] == NSOrderedSame) {
			msg = @"There was an internal error in Amazon EC2.";
			title = @"Internal Error";
		} else if ([string compare:@"InsufficientAddressCapacity"] == NSOrderedSame) {
			msg = @"Insufficient address capacity.";
			title = @"Error";
		} else if ([string compare:@"InsufficientInstanceCapacity"] == NSOrderedSame) {
			msg = @"Insufficient instance capacity.";
			title = @"Error";
		} else if ([string compare:@"Unavailable"] == NSOrderedSame) {
			msg = @"Amazon EC2 is currently unavailable.";
			title = @"Internal Error";
		} else if ([string compare:@"InvalidParameterValue" == NSOrderedSame]) {
			msg = @"The requested instance type's architecture is not compatible with the specified image.";
			title = @"Architecture mismatch";
		} else {
			msg = @"An unknown error occurred";
			title = @"Error";
		}
		
		if (msg != nil && title != nil) {
			if (!self.ec2Controller.errorDisplayed) {
				self.ec2Controller.errorDisplayed = TRUE;
				UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:msg
															   delegate:self cancelButtonTitle:@"OK"
													  otherButtonTitles:nil];
				[alert show];
				[alert release];
			}
		}
		
		return;
	}

	// NOT AN ERROR
	switch (self.reqType) {
		case DESCRIBE_INSTANCES:
			if ([self.lastElementName compare:@"reservationId"] == NSOrderedSame) {
				self.curGroupDict = [[NSMutableDictionary alloc] init];
				[self.tempInstanceData setValue:self.curGroupDict forKey:[string copy]];
				[self.tempOrderedGroups addObject:[string copy]];
				self.curSecurityGroups = [[NSMutableArray alloc] init];
			} else if ([self.lastElementName compare:@"instanceId"] == NSOrderedSame) {
				self.curInst = [[EC2Instance alloc] init];
				[self.curGroupDict setValue:self.curInst forKey:[string copy]];
				self.curInst.securityGroups = [self.curSecurityGroups copy];
			} else if ([self.lastElementName compare:@"groupId"] == NSOrderedSame) {
				[self.curSecurityGroups addObject:[string copy]];
			}

			if (self.curInst != nil) {
				[self.curInst addProperty:[self.lastElementName copy] value:[string copy]];
			}
			break;

		case DESCRIBE_AVAILABILITY_ZONES:
			if ([lastElementName compare:@"zoneName"] == NSOrderedSame) {
				self.curAvailZone = [string copy];
			} else if ([lastElementName compare:@"zoneState"] == NSOrderedSame) {
				if ([string compare:@"available"] == NSOrderedSame) {
					[self.tempAvailabilityZones addObject:[curAvailZone copy]];
				}
			}
			break;

		case DESCRIBE_KEY_PAIRS:
			if ([self.lastElementName compare:@"keyName"] == NSOrderedSame) {
				[self.tempKeyNames addObject:[string copy]];
			}
			break;

		case DESCRIBE_SECURITY_GROUPS:
			if ([self.lastElementName compare:@"groupName"] == NSOrderedSame
				&& [self.lastLastElementName compare:@"ownerId"] == NSOrderedSame) {
				[self.tempSecurityGroups addObject:[string copy]];
			}
			break;
		
		case GET_CONSOLE_OUTPUT:
			if ([self.lastElementName compare:@"output"] == NSOrderedSame) {
				
				
				NSLog(string);

				char* result;
				size_t len;
				char* s = [string cStringUsingEncoding:NSASCIIStringEncoding];

				/// WTF doesn't work!!!
				if (base64_decode_alloc(s, strlen(s), &result, &len)) {
					[self.ec2Controller setConsoleOutput:[NSString stringWithCString:result length:len]
						instanceId:self.targetInst groupId:self.targetInstGroup];

					NSLog(@"console output:");
					NSLog([NSString stringWithCString:result length:len]);
				}
			}
			break;
	}
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	switch (self.reqType) {
		case DESCRIBE_INSTANCES:
			if (self.tempInstanceData != nil) {
				self.ec2Controller.orderedGroups = [NSArray arrayWithArray:self.tempOrderedGroups];
				self.ec2Controller.instanceData = [NSDictionary dictionaryWithDictionary:self.tempInstanceData];
				[self.tempInstanceData release];
				self.tempInstanceData = nil;
				[self.tempOrderedGroups release];
				self.tempOrderedGroups = nil;
			}
			break;
		
		case DESCRIBE_AVAILABILITY_ZONES:
			if (self.tempAvailabilityZones != nil) {
				self.ec2Controller.availabilityZones = [NSArray arrayWithArray:self.tempAvailabilityZones];
				[self.tempAvailabilityZones release];
				self.tempAvailabilityZones = nil;
			}
			break;
		
		case DESCRIBE_KEY_PAIRS:
			if (self.tempKeyNames != nil) {
				self.ec2Controller.keyNames = [NSArray arrayWithArray:self.tempKeyNames];
				[self.tempKeyNames release];
				self.tempKeyNames = nil;
			}
			break;
			
		case DESCRIBE_SECURITY_GROUPS:
			if (self.tempSecurityGroups != nil) {
				self.ec2Controller.securityGroups = [NSArray arrayWithArray:self.tempSecurityGroups];
				[self.tempSecurityGroups release];
				self.tempSecurityGroups = nil;
			}
			break;

		case RUN_INSTANCES:
			[self.ec2Controller refreshInstanceData];
			break;
		
		case TERMINATE_INSTANCES:
			[self.ec2Controller refreshInstanceData];
			break;
	}

	// Refresh the view.
	[self.ec2Controller.rootViewController.navigationController.topViewController refreshEC2Callback:self.reqType];
	
	[self.ec2Controller.rootViewController hideLoadingScreen];
	self.reqType = NO_REQUEST;
}

@end
