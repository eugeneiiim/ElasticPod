//
//  InstanceGroupSetViewController.m
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/18/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import "InstanceGroupSetViewController.h"
#import "InstanceGroupViewController.h"
#import "EC2InstanceGroup.h"
#import "AddInstancesViewController.h"
#import "EC2DataController.h"

@implementation InstanceGroupSetViewController

@synthesize ec2Controller, account, accountsController;

- (InstanceGroupSetViewController*)initWithStyle:(UITableViewStyle)style account:(AWSAccount*)acct ec2Controller:(EC2DataController*)ec2Ctrl accountsController:(AccountsController*)accts_ctrl {
	if (self = [super initWithStyle:style]) {
		self.account = acct;
		self.ec2Controller = ec2Ctrl;
		self.accountsController = accts_ctrl;
	}
	return self;
}

- (void)viewDidLoad {
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.title = [account name];

	[super viewDidLoad];
}

- (void)refresh {
	[ec2Controller refreshInstanceData];
}

- (void)refreshEC2Callback:(RequestType)rt {
	[self.tableView reloadData];
}

- (void)add {
	AddInstancesViewController* aivc = [[AddInstancesViewController alloc] initWithStyle:UITableViewStyleGrouped ec2Controller:ec2Controller accountsController:self.accountsController];
	[self.navigationController pushViewController:aivc animated:YES];
	[aivc release];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [[ec2Controller getInstanceGroups] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];

	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MyIdentifier"] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
    
	// Get the object to display and set the value in the cell
	NSString* grp = [[ec2Controller getInstanceGroups] objectAtIndex:indexPath.row];
	cell.text = [NSString stringWithFormat:@"%@ (%d)", grp, [[self.ec2Controller getInstancesForGroup:grp] count]];

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString* grp = [ec2Controller getInstanceGroupAtIndex:indexPath.row];
	if (grp != nil) {
		InstanceGroupViewController* igvc = [[InstanceGroupViewController alloc] initWithStyle:UITableViewStylePlain
																				 instanceGroup:grp ec2Controller:ec2Controller
																			accountsController:accountsController];
		[[self navigationController] pushViewController:igvc animated:YES];
		[igvc release];
	} else {
		//NSLog(@"group is nil!");
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	switch (interfaceOrientation) {
		case UIInterfaceOrientationPortrait:
			return YES;
		case UIInterfaceOrientationLandscapeLeft:
			return YES;
		case UIInterfaceOrientationLandscapeRight:
			return YES;
		default:
			return NO;
	}
}

- (IBAction)addInstanceGroup:(id)sender {
	AddInstancesViewController* c = [[AddInstancesViewController alloc] initWithNibName:@"AddInstancesView" bundle:nil];
	c.ec2Controller = self.ec2Controller;
	[[self navigationController] pushViewController:c animated:YES];
	[c release];
}

- (void)dealloc {
	[super dealloc];
}

- (UITableViewCellEditingStyle)tableView: (UITableView *)tableView editingStyleForRowAtIndexPath: (NSIndexPath *)indexPath { 
	return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	// Remove this instance group.
	NSString* grp = [[ec2Controller getInstanceGroups] objectAtIndex:indexPath.row];
	[ec2Controller terminateInstanceGroup:grp];

	[self.tableView reloadData];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[ec2Controller.rootViewController updateViewForCurrentOrientation];
	[self resizeTable];
}

- (void)viewWillAppear:(BOOL)animated {
	self.ec2Controller.rootViewController.toolbar.hidden = FALSE;
	[self.tableView reloadData];
	[super viewWillAppear:animated];
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
			newheight = LANDSCAPE_TABLE_HEIGHT - self.ec2Controller.rootViewController.toolbar.frame.size.height;
			break;
		default:
			newheight = PORTRAIT_TABLE_HEIGHT - self.ec2Controller.rootViewController.toolbar.frame.size.height;
			break;
	}
	
	CGRect newframe = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, 
								 self.tableView.frame.size.width, newheight);
	[self.tableView setFrame:newframe];
}

@end
