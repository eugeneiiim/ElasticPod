//
//  InstanceGroupViewController.m
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/19/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import "InstanceGroupViewController.h"
#import "EC2Instance.h"
#import "InstanceViewController.h"
#import "EC2DataController.h"
#import "AddInstancesViewController.h"

@implementation InstanceGroupViewController

@synthesize ec2Controller, instanceGroup;

- (InstanceGroupViewController*)initWithStyle:(UITableViewStyle)style instanceGroup:(NSString*)grp ec2Controller:(EC2DataController*)ec2Ctrl {
	self.instanceGroup = grp;
	self.ec2Controller = ec2Ctrl;
	return [super initWithStyle:style];
}

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.title = instanceGroup;
    [super viewDidLoad];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[ec2Controller getInstancesForGroup:instanceGroup] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MyIdentifier"] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}

	// Get the object to display and set the value in the cell
	EC2Instance* inst = [ec2Controller getInstanceAtIndex:indexPath.row group:self.instanceGroup];
	if (inst == nil) {
		cell.text = @"MISSING INSTANCE";
		NSLog(@"ERROR instance is nil!");
	} else {
		cell.text = [inst getProperty:@"instanceId"];
		
		NSString* state = [inst getProperty:@"name"];
		if ([state compare:@"terminated"] == NSOrderedSame) {
			cell.contentView.backgroundColor = [UIColor redColor];
		} else if ([state compare:@"running"] == NSOrderedSame) {
			cell.contentView.backgroundColor = [UIColor greenColor];
		} else if ([state compare:@"booting"] == NSOrderedSame) {
			cell.contentView.backgroundColor = [UIColor yellowColor];
		}
	}

	return cell;
}

- (void)add {
	AddInstancesViewController* aivc = [[AddInstancesViewController alloc] initWithStyle:UITableViewStyleGrouped ec2Controller:ec2Controller];
	[self.navigationController pushViewController:aivc animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	InstanceViewController* ivc = [[InstanceViewController alloc] initWithStyle:UITableViewStyleGrouped
																	   instance:[[ec2Controller getInstancesForGroup:instanceGroup] objectAtIndex:indexPath.row]
																  ec2Controller:self.ec2Controller
																		  group:self.instanceGroup];
	[[self navigationController] pushViewController:ivc animated:YES];
	[ivc release];
}

- (void)refresh {
	[ec2Controller refreshInstanceData];
}

- (void)refreshEC2Callback {
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
	
	
	
	//[ec2Controller runInstances:model_instance n:num_instances];
}

- (UITableViewCellEditingStyle)tableView: (UITableView *)tableView editingStyleForRowAtIndexPath: (NSIndexPath *)indexPath { 
	return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	EC2Instance* inst = [[ec2Controller getInstancesForGroup:instanceGroup] objectAtIndex:indexPath.row];
	if (inst == nil) {
		NSLog(@"ERROR commitedit -- instance is nil!");
	} else {
		[ec2Controller terminateInstances:[NSArray arrayWithObject:inst]];
	}

	[self.tableView reloadData];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[ec2Controller.rootViewController updateViewForCurrentOrientation];
}

@end
