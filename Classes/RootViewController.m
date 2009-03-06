/*

File: RootViewController.m
Abstract: Creates a table view and serves as its delegate and data source.

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

#import "RootViewController.h"
#import "AccountsController.h"
#import "InstanceGroupSetViewController.h"
#import "AddAccountViewController.h"

@implementation RootViewController

@synthesize accountsController, toolbar, activityIndicator, loadingOverlay, loadingCount, loadingCountLock;

- (id)init {
	if (self = [super init]) {
		self.loadingCount = 0;
		self.loadingCountLock = [[NSLock alloc] init];
	}

	return self;
}

- (void)dealloc {
	[loadingOverlay release];
	[loadingCountLock release];
    [accountsController release];
	[activityIndicator release];
	[toolbar release];
    [super dealloc];
}

- (void)viewDidLoad {
	self.title = @"AWS Accounts";
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	toolbar = [[UIToolbar alloc] init];
	toolbar.barStyle = UIBarStyleDefault;
	[toolbar sizeToFit];

	UIBarButtonItem* refresh_button = [[UIBarButtonItem alloc]
									   initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
										target:self action:@selector(refreshButtonHandler:)];
	UIBarButtonItem* spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	UIBarButtonItem* add_account_button = [[UIBarButtonItem alloc]
										   initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self
										   action:@selector(addButtonHandler:)];
	[toolbar setItems:[NSArray arrayWithObjects:refresh_button,spacer,add_account_button,nil]];
	[refresh_button release];
	[spacer release];
	[add_account_button release];
	[self.navigationController.view addSubview:toolbar];

	self.loadingOverlay = [[UIView alloc] init];
	self.loadingOverlay.backgroundColor = [UIColor blackColor];
	self.loadingOverlay.alpha = 0.0;
	[self.navigationController.view addSubview:loadingOverlay];
	
	activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	
	[self.navigationController.view addSubview:activityIndicator];
	[self updateViewForCurrentOrientation];
	self.tableView.allowsSelectionDuringEditing = TRUE;

	[super viewDidLoad];
}

//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
//}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[self updateViewForCurrentOrientation];
	[self resizeTable];
}

- (void)viewWillAppear:(BOOL)animated {
	self.toolbar.hidden = FALSE;
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

- (void)add {
	[self addAccount];
}

- (IBAction)addButtonHandler:(id)sender {
	[[self.navigationController topViewController] add];
}

- (IBAction)refreshButtonHandler:(id)sender {
	[[self.navigationController topViewController] refresh];
}

- (void)refreshEC2Callback:(RequestType)rt {
}

- (void)refresh {
	[accountsController refreshEC2Controllers];
	[self.tableView reloadData];
}

- (void)addAccount {
	AddAccountViewController* c = [[AddAccountViewController alloc] initWithStyle:UITableViewStyleGrouped rootViewController:self];
	c.accountsController = self.accountsController;
	[[self navigationController] pushViewController:c animated:YES];
	[c release];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [accountsController countOfList];
}

- (void)updateViewForCurrentOrientation {
	CGFloat toolbarHeight = self.navigationController.navigationBar.frame.size.height;
	CGRect rootViewBounds = self.parentViewController.view.bounds;
	CGFloat rootViewHeight = CGRectGetHeight(rootViewBounds);
	CGFloat rootViewWidth = CGRectGetWidth(rootViewBounds);
	[toolbar setFrame:CGRectMake(0, rootViewHeight - toolbarHeight, rootViewWidth, toolbarHeight)];
	// self.toolbar.hidden = NO;
	
	[loadingOverlay setFrame:CGRectMake(0, 0, rootViewWidth, rootViewHeight)];
	
	CGFloat spinnerWidth = CGRectGetWidth(activityIndicator.bounds);
	[activityIndicator setFrame:CGRectMake(rootViewWidth/2 - spinnerWidth/2, rootViewHeight/2 - spinnerWidth/2, spinnerWidth, spinnerWidth)];
}

/*
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	//self.toolbar.hidden = YES;
}*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	switch (interfaceOrientation) {
		case UIInterfaceOrientationPortrait:
		case UIInterfaceOrientationLandscapeLeft:
		case UIInterfaceOrientationLandscapeRight:
			return YES;
		default:
			return NO;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MyIdentifier"] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}

	AWSAccount* acct = [accountsController objectInListAtIndex:indexPath.row];
	cell.text = acct.name;
	cell.hidesAccessoryWhenEditing = NO;

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.editing) {
		AddAccountViewController* c = [[AddAccountViewController alloc] initWithStyle:UITableViewStyleGrouped rootViewController:self];
		c.accountsController = accountsController;
		c.account = [accountsController objectInListAtIndex:indexPath.row];
		[[self navigationController] pushViewController:c animated:YES];
		[c release];
	} else {
		AWSAccount* acct = [accountsController objectInListAtIndex:indexPath.row];
		EC2DataController* ec2Ctrl = [accountsController ec2ControllerForAccount:[acct name]];

	//	igsvc.dataController = [[InstanceGroupSetDataController alloc] initWithAccount:acct viewController:igsvc ec2Controller:ec2Ctrl];

		/*
		 TODO maybe put this back in.
		if (ec2Ctrl.instDataState != INSTANCE_DATA_READY) {
			NSLog(@"INSTANCE DATA IS NOT READY FOR THIS ACCOUNT.");
		} else {*/
			InstanceGroupSetViewController* igsvc = [[InstanceGroupSetViewController alloc]
														initWithStyle:UITableViewStylePlain
														account:acct
														ec2Controller:ec2Ctrl
														accountsController:self.accountsController];

			[[self navigationController] pushViewController:igsvc animated:YES];
			[igsvc release];
		/*}*/
	}
}

- (UITableViewCellEditingStyle)tableView: (UITableView *)tableView editingStyleForRowAtIndexPath: (NSIndexPath *)indexPath { 
	return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	// Remove this account.
	[accountsController removeAccountAtIndex:indexPath.row];
	[self.tableView reloadData];
}

- (void)showLoadingScreen {
	[loadingCountLock lock];
	loadingCount++;
	if (loadingCount == 1) {
		[activityIndicator startAnimating];
		self.navigationController.view.userInteractionEnabled = false;
		self.loadingOverlay.alpha = 0.4;
	}
	[loadingCountLock unlock];
}

- (void)hideLoadingScreen {
	[loadingCountLock lock];
	loadingCount--;
	if (loadingCount == 0) {
		[activityIndicator stopAnimating];
		self.navigationController.view.userInteractionEnabled = true;
		self.loadingOverlay.alpha = 0.0;
	}
	[loadingCountLock unlock];
}

- (void)viewDidAppear:(BOOL)animated {
	[self resizeTable];
	[super viewDidAppear:animated];
}

- (void)resizeTable {
	CGFloat newheight;

	switch ([[UIDevice currentDevice] orientation]) {
		case UIDeviceOrientationLandscapeLeft:
		case UIDeviceOrientationLandscapeRight:
			newheight = LANDSCAPE_TABLE_HEIGHT - self.toolbar.frame.size.height;
			break;
		default:
			newheight = PORTRAIT_TABLE_HEIGHT - self.toolbar.frame.size.height;
			break;
	}

	CGRect newframe = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, 
								 self.tableView.frame.size.width, newheight);
	[self.tableView setFrame:newframe];
}

/*
// Overide to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	// TODO
}

 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
	 return YES;
 }
 */

@end
