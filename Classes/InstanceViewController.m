//
//  InstanceViewController.m
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/19/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import "InstanceViewController.h"
#import "EC2Instance.h"
#import "ButtonCell.h"

@implementation InstanceViewController

@synthesize instance, ec2Controller;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return TRUE;
}

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
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

	self.title = NSLocalizedString([instance getProperty:@"instanceId"], @"Master view navigation title");
    
	[super viewDidLoad];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0:
			switch (indexPath.row) {
				case 0:
					// Reboot
					[ec2Controller rebootInstances:[NSArray arrayWithObject:instance]];
					break;
				case 1:
					// Terminate
					[ec2Controller terminateInstances:[NSArray arrayWithObject:instance]];
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
			return 11;
        default:
			return -1;
    }
}

- (void)refresh {
	[self.tableView reloadData];
}

- (void)add {
	printf("TODO this action should not be allowed (doesn't make sense here)...\n");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	//UITableViewCell* cell;// = [tableView dequeueReusableCellWithIdentifier:@"tvc"];
	UITableViewCell* cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"tvc"] autorelease];
	
	switch(indexPath.section) {
		case 0:
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.textAlignment = UITextAlignmentCenter;
			
			// Controls -- reboot and terminate buttons
			switch (indexPath.row) {
				case 0:
					cell.text = @"Reboot";
					break;
				case 1:
					cell.text = @"Terminate";
					break;
			}
			
			return cell;

		case 1:			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			NSString *cellText = nil;

			// Information
			switch (indexPath.row) {
				case 0:
					cellText = [[NSString alloc] initWithFormat:@"Instance ID: %@", [instance getProperty:@"instanceId"]];
					break;
				case 1:
					cellText = [[NSString alloc] initWithFormat:@"Image ID: %@", [instance getProperty:@"imageId"]];
					break;
				case 2:
					cellText = [[NSString alloc] initWithFormat:@"State: %@", [instance getProperty:@"state"]];
					break;
				case 3:
					cellText = [[NSString alloc] initWithFormat:@"Private DNS: %@", [instance getProperty:@"privateDnsName"]];
					break;
				case 4:
					cellText = [[NSString alloc] initWithFormat:@"DNS: %@", [instance getProperty:@"dnsName"]];
					break;
				case 5:
					cellText = [[NSString alloc] initWithFormat:@"Key: %@", [instance getProperty:@"keyName"]];
					break;
				case 6:
					cellText = [[NSString alloc] initWithFormat:@"Type: %@", [instance getProperty:@"instanceType"]];
					break;
				case 7:
					cellText = [[NSString alloc] initWithFormat:@"Launch time: %@", [instance getProperty:@"launchTime"]];
					break;
				case 8:
					cellText = [[NSString alloc] initWithFormat:@"Placement: %@", [instance getProperty:@"placement"]];
					break;
				case 9:
					cellText = [[NSString alloc] initWithFormat:@"Kernel ID: %@", [instance getProperty:@"kernelId"]];
					break;
				case 10:
					cellText = [[NSString alloc] initWithFormat:@"Ramdisk: %@", [instance getProperty:@"ramdiskId"]];
					break;
				default:
					break;
			}
			
			cell.text = cellText;
			return cell;

		default:
			return nil;
			break;
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

@end
