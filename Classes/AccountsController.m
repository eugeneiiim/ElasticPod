/*

File: DataController.m

Abstract:
A simple controller class responsible for managing the application's data.
Typically this object would be able to load and save a file containing the
appliction's data. This example illustrates just the basic minimum: it creates
an array containing information about some plays and provides simple accessor
methods for the array and its contents.

Version: 2.6

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
("Apple") in consideration of your agreement to the following terms, and your
use, installation, modification or redistribution of this Apple software
constitutes acceptance of these terms.  If you do not agree with these terms,
please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject
to these terms, Apple grants you a personal, non-exclusive license, under
Apple's copyrights in this original Apple software (the "Apple Software"), to
use, reproduce, modify and redistribute the Apple Software, with or without
modifications, in source and/or binary forms; provided that if you redistribute
the Apple Software in its entirety and without modifications, you must retain
this notice and the following text and disclaimers in all such redistributions
of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may be used
to endorse or promote products derived from the Apple Software without specific
prior written permission from Apple.  Except as expressly stated in this notice,
no other rights or licenses, express or implied, are granted by Apple herein,
including but not limited to any patent rights that may be infringed by your
derivative works or by other works in which the Apple Software may be
incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2008 Apple Inc. All Rights Reserved.

*/

#import "AccountsController.h"
#import "EC2DataController.h"

#define EC2PHONE_ACCOUNTS @"EC2PHONE_ACCOUNTS"

@implementation AccountsController

@synthesize nameToAccount, accountEc2Controllers, rootViewController;

- (id)init:(RootViewController*)rvc {
	if (self = [super init]) {
		self.rootViewController = rvc;
		[self loadAccounts];
	}
	return self;
}

- (void)addAccount:(AWSAccount*)acct {
	if (acct.name == nil || [acct.name length] == 0) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Account is missing a name."
													   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else if (acct.access_key == nil || [acct.access_key length] == 0) {
		NSString* msg = [NSString stringWithFormat:@"Account \"%@\" is missing an access key.", acct.name];
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:msg
													   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else if (acct.secret_key == nil || [acct.secret_key length] == 0) {
		NSString* msg = [NSString stringWithFormat:@"Account \"%@\" is missing a secret key.", acct.name];
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:msg
													   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else {
		AWSAccount* existing = [self.nameToAccount objectForKey:[acct name]];
		if (existing) {
			NSString* msg = [NSString stringWithFormat:@"Account \"%@\" already exists.", [acct name]];
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Account exists" message:msg
													   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		} else {
			[self.nameToAccount setValue:acct forKey:acct.name];
			EC2DataController* c = [[EC2DataController alloc] initWithAccount:acct rootViewController:rootViewController];
			[c refreshInstanceData];
			[self.accountEc2Controllers setValue:c forKey:acct.name];
			[self saveAccounts];
		}
	}
}

- (void)updateAccount:(NSString*)prev_name newAccount:(AWSAccount*)new {
	[self.nameToAccount removeObjectForKey:prev_name];
	[self.nameToAccount setValue:new forKey:new.name];

	EC2DataController* c = [self.accountEc2Controllers valueForKey:prev_name];
	c.account = new;
	[self.accountEc2Controllers removeObjectForKey:prev_name];
	[self.accountEc2Controllers setValue:c forKey:new.name];

	[c refreshInstanceData];
	[self saveAccounts];
}

- (EC2DataController*)ec2ControllerForAccount:(NSString*)acct {
	return [self.accountEc2Controllers valueForKey:acct];
}

// Accessor methods for list
- (unsigned)countOfList {
	return [[nameToAccount allKeys] count];
}

- (AWSAccount*)objectInListAtIndex:(unsigned)theIndex {
	return [[nameToAccount allValues] objectAtIndex:theIndex];
}

- (void)dealloc {
	[nameToAccount release];
	[super dealloc];
}

- (void)saveAccounts {
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	for (NSString* name in [nameToAccount allKeys]) {
		AWSAccount* acct = [nameToAccount objectForKey:name];
		NSDictionary* d = [NSDictionary dictionaryWithObjectsAndKeys:[acct secret_key],@"secret",
						   [acct access_key],@"access",
						   acct.defaultImageId,@"defaultImageId",
						   acct.defaultKernelId,@"defaultKernelId",
						   acct.defaultRamdiskId,@"defaultRamdiskId",
						   nil];
		[dict setValue:d forKey:[acct name]];
	}

	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:dict forKey:EC2PHONE_ACCOUNTS];
	[userDefaults synchronize];
}

- (void)loadAccounts {
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	NSDictionary* accounts = [userDefaults dictionaryForKey:EC2PHONE_ACCOUNTS];

	/*
	if (accounts == nil) {
		accounts = [NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:@"ACCESSKEY",@"access",@"SECRETKEY",@"secret",nil],@"Eugene",nil];
		[userDefaults setObject:accounts forKey:EC2PHONE_ACCOUNTS];
		[userDefaults synchronize];
	}*/

	self.nameToAccount = [[NSMutableDictionary alloc] init];
	self.accountEc2Controllers = [[NSMutableDictionary alloc] init];

	if (accounts != nil) {
		for (NSString* a in [accounts allKeys]) {
			NSDictionary* dict = [accounts valueForKey:a];
			AWSAccount* acct = [AWSAccount accountWithName:a accessKey:[dict valueForKey:@"access"] secretKey:[dict valueForKey:@"secret"]];
			acct.defaultImageId = [dict valueForKey:@"defaultImageId"];
			[self.nameToAccount setValue:acct forKey:a];

			EC2DataController* c = [[EC2DataController alloc] initWithAccount:acct rootViewController:rootViewController];
			[c refreshInstanceData];
			[self.accountEc2Controllers setValue:c forKey:acct.name];
		}
	}
}

- (void)removeAccountAtIndex:(NSInteger)index {
	AWSAccount* acct = [[self.nameToAccount allValues] objectAtIndex:index];
	[self.nameToAccount removeObjectForKey:acct.name];
	[self.accountEc2Controllers removeObjectForKey:acct.name];
	[self saveAccounts];
}

- (void)refreshEC2Controllers {
	for (EC2DataController* e in [accountEc2Controllers allValues]) {
		[e refreshInstanceData];
	}
}

- (void)setDefaultImageIdForAccount:(NSString*)acct imageId:(NSString*)imageid {
	AWSAccount* a = [self.nameToAccount valueForKey:acct];
	a.defaultImageId = imageid;
	[self.nameToAccount setValue:a forKey:acct];
	[self saveAccounts];
}

- (NSString*)getDefaultImageIdForAccount:(NSString*)acct {
	return [[self.nameToAccount valueForKey:acct] defaultImageId];
}

- (void)setDefaultRamdiskIdForAccount:(NSString*)acct ramdiskId:(NSString*)ramdiskid {
	AWSAccount* a = [self.nameToAccount valueForKey:acct];
	a.defaultRamdiskId = ramdiskid;
	[self.nameToAccount setValue:a forKey:acct];
	[self saveAccounts];
}

- (NSString*)getDefaultRamdiskIdForAccount:(NSString*)acct {
	return [[self.nameToAccount valueForKey:acct] defaultRamdiskId];
}

- (void)setDefaultKernelIdForAccount:(NSString*)acct kernelId:(NSString*)kernelid {
	AWSAccount* a = [self.nameToAccount valueForKey:acct];
	a.defaultKernelId = kernelid;
	[self.nameToAccount setValue:a forKey:acct];
	[self saveAccounts];
}

- (NSString*)getDefaultKernelIdForAccount:(NSString*)acct {
	return [[self.nameToAccount valueForKey:acct] defaultKernelId];
}

@end
