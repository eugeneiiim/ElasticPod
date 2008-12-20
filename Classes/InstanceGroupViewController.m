//
//  InstanceGroupViewController.m
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/19/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import "InstanceGroupViewController.h"
#import "InstanceGroupDataController.h"
#import "EC2Instance.h"
#import "InstanceViewController.h"
#import "EC2DataController.h"

@implementation InstanceGroupViewController

@synthesize dataController, ec2Controller;

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.title = dataController.instance_group;
    [super viewDidLoad];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [dataController countOfList];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MyIdentifier"] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}

	// Get the object to display and set the value in the cell
	cell.text = [[dataController objectInListAtIndex:indexPath.row] getProperty:@"instanceId"];

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	InstanceViewController* ivc = [[InstanceViewController alloc] initWithStyle:UITableViewStyleGrouped];
	ivc.instance = [[dataController list] objectAtIndex:indexPath.row];
	ivc.ec2Controller = ec2Controller;
	
	[[self navigationController] pushViewController:ivc animated:YES];
	[ivc release];
}

- (void)refresh {
	[ec2Controller refreshInstanceData:@selector(ec2RefreshCallback:) target:self];
}

- (void)ec2RefreshCallback {
	[dataController refresh];
	[self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return TRUE;
}

- (void)dealloc {
    [super dealloc];
}

- (IBAction)addInstances:(id)sender {
	EC2Instance* model_instance;
	NSInteger num_instances;
	
	[ec2Controller runInstances:model_instance n:num_instances];
}

- (void)add {
	printf("TODO prompt to add new instances\n");
	//[navigationController pushNavigationItem: animated:YES];
}

- (UITableViewCellEditingStyle)tableView: (UITableView *)tableView editingStyleForRowAtIndexPath: (NSIndexPath *)indexPath { 
	return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	EC2Instance* inst = [dataController objectInListAtIndex:indexPath.row];
	[ec2Controller terminateInstances:[NSArray arrayWithObject:inst]];
	[self.tableView reloadData];
}

@end
