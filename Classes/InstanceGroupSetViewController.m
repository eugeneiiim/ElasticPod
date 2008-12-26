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

@synthesize ec2Controller, account;

- (InstanceGroupSetViewController*)initWithStyle:(UITableViewStyle)style account:(AWSAccount*)acct ec2Controller:(EC2DataController*)ec2Ctrl {
	self.account = acct;
	self.ec2Controller = ec2Ctrl;
	return [super initWithStyle:style];
}

- (void)viewDidLoad {
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.title = [account name];

	//[ec2Controller refreshInstanceData:nil/*@selector(ec2RefreshCallback:)*/ target:self];
	//[self refresh];

	[super viewDidLoad];
}

- (void)refresh {
	printf("instance group set view controller REFRESH\n");
	[ec2Controller refreshInstanceData:@selector(ec2RefreshCallback:) target:self];

	[self ec2RefreshCallback];
}

- (void)ec2RefreshCallback {
	printf("EC2 REFRESH CALLBACK\n");
	[self.tableView reloadData];
}

- (void)add {
	AddInstancesViewController* aivc = [[AddInstancesViewController alloc] initWithStyle:UITableViewStyleGrouped ec2Controller:ec2Controller];
	[self.navigationController pushViewController:aivc animated:YES];
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
	cell.text = [[ec2Controller getInstanceGroups] objectAtIndex:indexPath.row];

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString* grp = [[ec2Controller getInstanceGroups] objectAtIndex:indexPath.row];
	InstanceGroupViewController* igvc = [[InstanceGroupViewController alloc] initWithStyle:UITableViewStylePlain
																			 instanceGroup:grp ec2Controller:ec2Controller];

	[[self navigationController] pushViewController:igvc animated:YES];
	[igvc release];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return TRUE;
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

@end
