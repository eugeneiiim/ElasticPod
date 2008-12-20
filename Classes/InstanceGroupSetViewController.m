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

@synthesize dataController, ec2Controller;

- (void)viewDidLoad {
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.title = [[dataController account] name];

	[ec2Controller refreshInstanceData:nil/*@selector(ec2RefreshCallback:)*/ target:self];
	
	[self refresh];
	[super viewDidLoad];
}

- (void)refresh {
	printf("instance group set view controller REFRESH\n");
	//[ec2Controller refreshInstanceData:@selector(ec2RefreshCallback:) target:self];

	[self ec2RefreshCallback];
}

- (void)ec2RefreshCallback {
	printf("EC2 REFRESH CALLBACK\n");
	[dataController refresh];
	[self.tableView reloadData];
}

- (void)add {
	printf("TODO prompt to add new instance set\n");
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [dataController countOfList];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];

	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MyIdentifier"] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
    
	// Get the object to display and set the value in the cell
	cell.text = [dataController objectInListAtIndex:indexPath.row];

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	InstanceGroupViewController* igvc = [[InstanceGroupViewController alloc] initWithStyle:UITableViewStylePlain];
	NSString* grp = [dataController objectInListAtIndex:indexPath.row];
	igvc.dataController = [[InstanceGroupDataController alloc] init:grp viewController:igvc account:[dataController account] ec2Controller:ec2Controller];	
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
	NSString* grp = [dataController objectInListAtIndex:indexPath.row];
	[ec2Controller terminateInstanceGroup:grp];

	[dataController removeGroupAtIndex:indexPath.row];
	[self.tableView reloadData];
}

@end
