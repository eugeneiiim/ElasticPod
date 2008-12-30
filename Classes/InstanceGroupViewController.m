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

@synthesize ec2Controller, instanceGroup, accountsController;

- (InstanceGroupViewController*)initWithStyle:(UITableViewStyle)style instanceGroup:(NSString*)grp ec2Controller:(EC2DataController*)ec2Ctrl accountsController:(AccountsController*)accts_ctrl {
	if (self = [super initWithStyle:style]) {
		self.instanceGroup = grp;
		self.ec2Controller = ec2Ctrl;
		self.accountsController = accts_ctrl;
	}
	return self;
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
			cell.textColor = [UIColor colorWithRed:0.8 green:0.0 blue:0.0 alpha:1.0];
		} else if ([state compare:@"running"] == NSOrderedSame) {
			cell.textColor = [UIColor colorWithRed:0.2 green:0.5 blue:0.0 alpha:1.0];
		} else if ([state compare:@"pending"] == NSOrderedSame) {
			cell.textColor = [UIColor colorWithRed:0.8 green:0.6 blue:0.2 alpha:1.0];
		} else if ([state compare:@"shutting-down"] == NSOrderedSame) {
			cell.textColor = [UIColor colorWithRed:0.8 green:0.0 blue:0.0 alpha:1.0];
		}
	}

	return cell;
}

- (void)add {
	AddInstancesViewController* aivc = [[AddInstancesViewController alloc] initWithStyle:UITableViewStyleGrouped ec2Controller:self.ec2Controller accountsController:self.accountsController];
	[self.navigationController pushViewController:aivc animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	InstanceViewController* ivc = [[InstanceViewController alloc] initWithStyle:UITableViewStyleGrouped
																	   instance:[[ec2Controller getInstancesForGroup:instanceGroup] objectAtIndex:indexPath.row]
																  ec2Controller:self.ec2Controller
																		  group:self.instanceGroup
															 accountsController:self.accountsController];
	[[self navigationController] pushViewController:ivc animated:YES];
	[ivc release];
}

- (void)refresh {
	[ec2Controller refreshInstanceData];
}

- (void)refreshEC2Callback:(RequestType)rt {
	[self.tableView reloadData];
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

- (void)dealloc {
    [super dealloc];
}

- (UITableViewCellEditingStyle)tableView: (UITableView *)tableView editingStyleForRowAtIndexPath: (NSIndexPath *)indexPath { 
	return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	EC2Instance* inst = [[ec2Controller getInstancesForGroup:instanceGroup] objectAtIndex:indexPath.row];
	if (inst == nil) {
		//NSLog(@"ERROR commitedit -- instance is nil!");
	} else {
		[ec2Controller terminateInstances:[NSArray arrayWithObject:inst]];
	}

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
