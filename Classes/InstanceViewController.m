//
//  InstanceViewController.m
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/19/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import "InstanceViewController.h"
#import "EC2Instance.h"
#import "AddInstancesViewController.h"

@implementation InstanceViewController

@synthesize instance, ec2Controller, index, group, reboot_cell, terminate_cell, lastAction;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return TRUE;
}

- (InstanceViewController*)initWithStyle:(UITableViewStyle)style instance:(EC2Instance*)inst ec2Controller:(EC2DataController*)ec2Ctrl
								   group:(NSString*)grp {
	if ([super initWithStyle:style]) {
		self.instance = inst;
		self.ec2Controller = ec2Ctrl;
		self.group = grp;
		self.lastAction = NO_ACTION;
	}
	return self;
}

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
	if ([[ec2Controller getInstancesForGroup:group] count] > 1) {
		// Up/down arrows
		UISegmentedControl *segmentedControl = [[[UISegmentedControl alloc] initWithItems:
												 [NSArray arrayWithObjects:
												  [UIImage imageNamed:@"up.png"],
												[UIImage imageNamed:@"down.png"],
												  nil]] autorelease];
		[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
		segmentedControl.frame = CGRectMake(0, 0, 90, 30);
		segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
		segmentedControl.momentary = YES;

		UIBarButtonItem *segmentBarItem = [[[UIBarButtonItem alloc] initWithCustomView:segmentedControl] autorelease];
		self.navigationItem.rightBarButtonItem = segmentBarItem;
	}

	self.title = [instance getProperty:@"instanceId"];

	[super viewDidLoad];
}

- (IBAction)segmentAction:(id)sender {
	NSArray* neighs = [ec2Controller getInstancesForGroup:group];
	if (neighs == nil) {
		NSLog(@"ERROR! no neighbors for group %@", group);
		return;
	}
	NSInteger num_neighs = [neighs count];

	NSInteger next_index;
	UISegmentedControl* seg = sender;
	switch (seg.selectedSegmentIndex) {
		case 0:
			next_index = (index+1) % num_neighs;
			NSLog(@"%d", next_index);
			break;
		case 1:
			next_index = (index-1+num_neighs) % num_neighs;
			NSLog(@"%d", next_index);
			break;
	}

	// Just reuse the current instance.
	self.instance = [neighs objectAtIndex:next_index];
	self.title = [instance getProperty:@"instanceId"];
	self.index = next_index;
	[self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case 0:
			switch (self.lastAction) {
				case REBOOT:
					[ec2Controller rebootInstances:[NSArray arrayWithObject:instance]];
					break;
				case TERMINATE:
					[ec2Controller terminateInstances:[NSArray arrayWithObject:instance]];
					break;
				default:
					break;
			}
			self.lastAction = NO_ACTION;
			break;
		case 1:
			break;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UIAlertView* alert;
	
	switch (indexPath.section) {
		case 0:
			switch (indexPath.row) {
				case 0:
					// Reboot
					self.lastAction = REBOOT;

					alert = [[UIAlertView alloc] initWithTitle:@"Warning"
													   message:[NSString stringWithFormat:@"Really reboot %@?", [instance getProperty:@"instanceId"]]
													  delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:nil];
					[alert addButtonWithTitle:@"No"];
					[alert show];
					[alert release];
					break;
				case 1:
					// Terminate
					self.lastAction = TERMINATE;

					alert = [[UIAlertView alloc] initWithTitle:@"Warning"
													message:[NSString stringWithFormat:@"Really terminate %@?", [instance getProperty:@"instanceId"]]
													  delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:nil];
					[alert addButtonWithTitle:@"No"];
					[alert show];
					[alert release];
					break;
				default:
					return;
			}
			break;
		default:
			return;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
		case 0:
			return 2;
        case 1:
			return 14;
        default:
			return 0;
    }
}

- (void)refresh {
	[ec2Controller refreshInstanceData];
}

- (void)refreshEC2Callback {
	EC2Instance* new_inst = [[[ec2Controller instanceData] valueForKey:self.group] valueForKey:[self.instance getProperty:@"instanceId"]];
	if (new_inst != nil) {
		self.instance = new_inst;
		[self.tableView reloadData];
	} else {
		NSLog(@"ERROR instance is now null.  Might be gone, might have been a failed request.");
	}
}

- (void)add {
	AddInstancesViewController* aivc = [[AddInstancesViewController alloc] initWithStyle:UITableViewStyleGrouped ec2Controller:ec2Controller];
	[self.navigationController pushViewController:aivc animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	//UITableViewCell* cell;// = [tableView dequeueReusableCellWithIdentifier:@"tvc"];
	//UITableViewCell* cell;

	DetailCell* cell;
	
	switch(indexPath.section) {
		case 0:
			// Controls -- reboot and terminate buttons
			switch (indexPath.row) {
				case 0:
					if (self.reboot_cell == nil) {
						self.reboot_cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"tvc"] autorelease];
						self.reboot_cell.accessoryType = UITableViewCellAccessoryNone;
						self.reboot_cell.textAlignment = UITextAlignmentCenter;
						self.reboot_cell.text = @"Reboot";
						self.reboot_cell.selectionStyle = UITableViewCellSelectionStyleNone;
					}
					return self.reboot_cell;
				case 1:
					if (self.terminate_cell == nil) {
						self.terminate_cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"tvc"] autorelease];
						self.terminate_cell.accessoryType = UITableViewCellAccessoryNone;
						self.terminate_cell.textAlignment = UITextAlignmentCenter;
						self.terminate_cell.text = @"Terminate";
						self.terminate_cell.selectionStyle = UITableViewCellSelectionStyleNone;
					}
					return self.terminate_cell;
			}

		case 1:
			//cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"tvc"] autorelease];
			//cell.selectionStyle = UITableViewCellSelectionStyleNone;
			//NSString *cellText = nil;
			
			cell = [[[DetailCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"DetailCell"] autorelease];
			cell.name.userInteractionEnabled = false;
			[cell setSelectionStyle:UITableViewCellSelectionStyleNone];

			// Information
			switch (indexPath.row) {
				case 0:
					cell.prompt.text = @"Name";
					cell.name.text = [instance getProperty:@"instanceId"];
					break;
				case 1:
					cell.prompt.text = @"Image ID";
					cell.name.text = [instance getProperty:@"imageId"];
					break;
				case 2:
					cell.prompt.text = @"State";
					cell.name.text = [instance getProperty:@"name"]; // TODO FIX ME
					break;
				case 3:
					cell.prompt.text = @"Private DNS";
					cell.name.text = [instance getProperty:@"privateDnsName"];
					break;
				case 4:
					cell.prompt.text = @"DNS";
					cell.name.text = [instance getProperty:@"dnsName"];
					break;
				case 5:
					cell.prompt.text = @"Security Groups";
					NSMutableString* str = [NSMutableString stringWithString:@""];
					for (NSString* grp in self.instance.securityGroups) {
						[str appendFormat:@"%@ ", grp];
					}
					
					cell.name.text = str;
					break;
				case 6:
					cell.prompt.text = @"Reason";
					cell.name.text = [instance getProperty:@"reason"];
					break;
				case 7:
					cell.prompt.text = @"Key";
					cell.name.text = [instance getProperty:@"keyName"];
					break;
				case 8:
					cell.prompt.text = @"Index";
					cell.name.text = [instance getProperty:@"amiLaunchIndex"];
					break;
				case 9:
					cell.prompt.text = @"Type";
					cell.name.text = [instance getProperty:@"instanceType"];
					break;
				case 10:
					cell.prompt.text = @"Launch Time";
					cell.name.text = [instance getProperty:@"launchTime"];
					break;
				case 11:
					cell.prompt.text = @"Zone";
					cell.name.text = [instance getProperty:@"availabilityZone"];  // TODO FIX
					break;
				case 12:
					cell.prompt.text = @"Kernel ID";
					cell.name.text = [instance getProperty:@"kernelId"];
					break;
				case 13:
					cell.prompt.text = @"Ramdisk ID";
					cell.name.text = [instance getProperty:@"ramdiskId"];
					break;
				default:
					break;
			}

			return cell;

		default:
			return nil;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return @"Controls";
		case 1:
			return @"Info";
		default:
			return nil;
	}
}

- (void)dealloc {
	[super dealloc];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[ec2Controller.rootViewController updateViewForCurrentOrientation];
}

@end
