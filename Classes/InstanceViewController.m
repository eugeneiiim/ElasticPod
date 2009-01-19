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

@synthesize instance, ec2Controller, index, group, reboot_cell, terminate_cell, lastAction, accountsController;

- (InstanceViewController*)initWithStyle:(UITableViewStyle)style instance:(EC2Instance*)inst ec2Controller:(EC2DataController*)ec2Ctrl
								   group:(NSString*)grp accountsController:(AccountsController*)accts_ctrl {
	if (self = [super initWithStyle:style]) {
		self.instance = inst;
		self.ec2Controller = ec2Ctrl;
		self.group = grp;
		self.lastAction = NO_ACTION;
		self.accountsController = accts_ctrl;
	}
	return self;
}

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
		//NSLog(@"ERROR! no neighbors for group %@", group);
		return;
	}
	NSInteger num_neighs = [neighs count];

	NSInteger next_index;
	UISegmentedControl* seg = sender;
	switch (seg.selectedSegmentIndex) {
		case 0:
			next_index = (index+1) % num_neighs;
			break;
		case 1:
			next_index = (index-1+num_neighs) % num_neighs;
			break;
	}

	// Just reuse the current instance.
	self.instance = [neighs objectAtIndex:next_index];
	self.title = [instance getProperty:@"instanceId"];
	self.index = next_index;
	[self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if ([self showRebootButton] || [self showTerminateButton]) {
		return 2;
	} else {
		return 1;
	}
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

- (void)rebootConfirmation {
	// Reboot
	self.lastAction = REBOOT;
	
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Warning"
									   message:[NSString stringWithFormat:@"Really reboot %@?", [instance getProperty:@"instanceId"]]
									  delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:nil];
	[alert addButtonWithTitle:@"No"];
	[alert show];
	[alert release];
}

- (void)terminateConfirmation {
	// Terminate
	self.lastAction = TERMINATE;
	
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Warning"
									   message:[NSString stringWithFormat:@"Really terminate %@?", [instance getProperty:@"instanceId"]]
									  delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:nil];
	[alert addButtonWithTitle:@"No"];
	[alert show];
	[alert release];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UIWebView* webview;
	UIViewController* vc;
	switch (indexPath.section) {
		case 0:
			switch (indexPath.row) {
				case 0:
					if ([self showRebootButton]) {
						[self rebootConfirmation];
					} else if ([self showTerminateButton]) {
						[self terminateConfirmation];
					}
					break;
				case 1:
					if ([self showRebootButton] && [self showTerminateButton]) {
						[self terminateConfirmation];
					}
					break;
				default:
					return;
			}
			break;
		case 1:
			switch (indexPath.row) {
				case 2:
					if ([[self.instance getProperty:@"dnsName"] length] != 0) {
						vc = [[UIViewController alloc] init];
						webview = [[UIWebView alloc] init];
						vc.title = [self.instance getProperty:@"dnsName"];
						vc.view = webview;
						//[vc loadView];

						//NSLog([self.instance getProperty:@"dnsName"]);
					
						NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@",[self.instance getProperty:@"dnsName"]]];
						//NSURL* url = [NSURL URLWithString:@"http://www.google.com"];
					
						NSURLRequest* req = [NSURLRequest requestWithURL:url];
						[webview loadRequest:req];
					
						self.ec2Controller.rootViewController.toolbar.hidden = TRUE;
						[self.navigationController pushViewController:vc animated:YES];
						[webview release];
					}
					break;
				default:
					break;
			}
			break;
		default:
			return;
	}
}

- (BOOL)showTerminateButton {
	return [[self.instance getProperty:@"name"] compare:@"running"] == NSOrderedSame
		|| [[self.instance getProperty:@"name"] compare:@"pending"] == NSOrderedSame;
}

- (BOOL)showRebootButton {
	return [[self.instance getProperty:@"name"] compare:@"running"] == NSOrderedSame;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger rows;
    switch (section) {
		case 0:
			rows = 0;
			if ([self showRebootButton]) {
				rows += 1;
			}
			if ([self showTerminateButton]) {
				rows += 1;
			}
			
			if (rows > 0) {
				return rows;
			} else {
				return 14;
			}
        case 1:
			return 14;
        default:
			return 0;
	}
}

- (void)refresh {
	[ec2Controller refreshInstanceData];
}

- (void)refreshEC2Callback:(RequestType)rt {
	EC2Instance* new_inst = [[[ec2Controller instanceData] valueForKey:self.group] valueForKey:[self.instance getProperty:@"instanceId"]];
	if (new_inst != nil) {
		self.instance = new_inst;
		[self.tableView reloadData];
	} else {
		NSLog(@"ERROR instance is now null.  Might be gone, might have been a failed request.");
	}
}

- (void)add {
	AddInstancesViewController* aivc = [[AddInstancesViewController alloc] initWithStyle:UITableViewStyleGrouped ec2Controller:ec2Controller accountsController:self.accountsController];
	[self.navigationController pushViewController:aivc animated:YES];
	[aivc release];
}

- (UITableViewCell*)getTerminateButtonCell {
	if (self.terminate_cell == nil) {
		self.terminate_cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"tvc"] autorelease];
		self.terminate_cell.accessoryType = UITableViewCellAccessoryNone;
		
		UILabel* text = [[UILabel alloc] init];
		text.text = @"Terminate";
		text.textAlignment = UITextAlignmentLeft;
		text.font = [UIFont boldSystemFontOfSize:18.0];
		
		CGRect rect = CGRectInset(self.terminate_cell.contentView.frame, 10, 10);
		rect.size.width -= 20;
		text.frame = rect;
		
		[self.terminate_cell.contentView addSubview:text];
		[text release];
		
		self.terminate_cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	return self.terminate_cell;
}

- (UITableViewCell*)getRebootButtonCell {
	if (self.reboot_cell == nil) {
		self.reboot_cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"tvc"] autorelease];
		self.reboot_cell.accessoryType = UITableViewCellAccessoryNone;
		
		UILabel* text = [[UILabel alloc] init];
		text.text = @"Reboot";
		text.textAlignment = UITextAlignmentLeft;
		text.font = [UIFont boldSystemFontOfSize:18.0];
		
		CGRect rect = CGRectInset(self.reboot_cell.contentView.frame, 10, 10);
		rect.size.width -= 20;
		text.frame = rect;
		
		[self.reboot_cell.contentView addSubview:text];
		self.reboot_cell.contentView.autoresizesSubviews = TRUE;
		
		self.reboot_cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	return self.reboot_cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	//UITableViewCell* cell;// = [tableView dequeueReusableCellWithIdentifier:@"tvc"];
	//UITableViewCell* cell;

	NSInteger section = indexPath.section;
	
	if (section == 0 && !([self showRebootButton] || [self showTerminateButton])) {
		section = 1;
	}
	
	LabelCell* cell;
	switch(section) {
		case 0:
			// Controls -- reboot and terminate buttons
			switch (indexPath.row) {
				case 0:
					if ([self showRebootButton]) {
						return [self getRebootButtonCell];
					} else if ([self showTerminateButton]) {
						return [self getTerminateButtonCell];
					} else {
						return nil;
					}
				case 1:
					if ([self showRebootButton] && [self showTerminateButton]) {
						return [self getTerminateButtonCell];
					} else {
						return nil;
					}
			}

		case 1:
			// Information
			switch (indexPath.row) {
				case 0:
					cell = [[[LabelCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"DetailCell" inputOffset:85] autorelease];
					[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
					
					cell.prompt.text = @"Instance ID";
					cell.name.text = [instance getProperty:@"instanceId"];
					break;
				case 1:
					cell = [[[LabelCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"DetailCell" inputOffset:48] autorelease];
					[cell setSelectionStyle:UITableViewCellSelectionStyleNone];					
					
					cell.prompt.text = @"State";
					cell.name.text = [instance getProperty:@"name"]; // TODO FIX ME
					
					if ([cell.name.text compare:@"terminated"] == NSOrderedSame) {
						cell.name.textColor = [UIColor colorWithRed:0.8 green:0.0 blue:0.0 alpha:1.0];
					} else if ([cell.name.text compare:@"running"] == NSOrderedSame) {
						cell.name.textColor = [UIColor colorWithRed:0.2 green:0.5 blue:0.0 alpha:1.0];
					} else if ([cell.name.text compare:@"pending"] == NSOrderedSame) {
						cell.name.textColor = [UIColor colorWithRed:0.8 green:0.6 blue:0.2 alpha:1.0];
					} else if ([cell.name.text compare:@"shutting-down"] == NSOrderedSame) {
						cell.name.textColor = [UIColor colorWithRed:0.8 green:0.0 blue:0.0 alpha:1.0];
					}

					break;
				case 2:
					cell = [[[LabelCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"DetailCell" inputOffset:42] autorelease];
					[cell setSelectionStyle:UITableViewCellSelectionStyleNone];					
					
					cell.prompt.text = @"DNS";
					cell.name.text = [self.instance getProperty:@"dnsName"];
					if ([[self.instance getProperty:@"dnsName"] length] != 0) {
						cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					}
					break;
				case 3:
					cell = [[[LabelCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"DetailCell" inputOffset:90] autorelease];
					[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
										
					cell.prompt.text = @"Private DNS";
					cell.name.text = [instance getProperty:@"privateDnsName"];
					break;
				case 4:
					cell = [[[LabelCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"DetailCell" inputOffset:68] autorelease];
					[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
					
					cell.prompt.text = @"Image ID";
					cell.name.text = [instance getProperty:@"imageId"];
					break;
				case 5:
					cell = [[[LabelCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"DetailCell" inputOffset:119] autorelease];
					[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
					
					cell.prompt.text = @"Security Groups";
					NSMutableString* str = [NSMutableString stringWithString:@""];
					for (NSString* grp in self.instance.securityGroups) {
						[str appendFormat:@"%@ ", grp];
					}
					
					cell.name.text = str;
					break;
				case 6:
					cell = [[[LabelCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"DetailCell" inputOffset:63] autorelease];
					[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
					
					cell.prompt.text = @"Reason";
					cell.name.text = [instance getProperty:@"reason"];
					break;
				case 7:
					cell = [[[LabelCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"DetailCell" inputOffset:38] autorelease];
					[cell setSelectionStyle:UITableViewCellSelectionStyleNone];					
					
					cell.prompt.text = @"Key";
					cell.name.text = [instance getProperty:@"keyName"];
					break;
				case 8:
					cell = [[[LabelCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"DetailCell" inputOffset:48] autorelease];
					[cell setSelectionStyle:UITableViewCellSelectionStyleNone];					
					
					cell.prompt.text = @"Index";
					cell.name.text = [instance getProperty:@"amiLaunchIndex"];
					break;
				case 9:
					cell = [[[LabelCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"DetailCell" inputOffset:48] autorelease];
					[cell setSelectionStyle:UITableViewCellSelectionStyleNone];					
					
					cell.prompt.text = @"Type";
					cell.name.text = [instance getProperty:@"instanceType"];
					break;
				case 10:
					cell = [[[LabelCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"DetailCell" inputOffset:95] autorelease];
					[cell setSelectionStyle:UITableViewCellSelectionStyleNone];					
					
					cell.prompt.text = @"Launch Time";
					cell.name.text = [instance getProperty:@"launchTime"];
					break;
				case 11:
					cell = [[[LabelCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"DetailCell" inputOffset:48] autorelease];
					[cell setSelectionStyle:UITableViewCellSelectionStyleNone];					
					
					cell.prompt.text = @"Zone";
					cell.name.text = [instance getProperty:@"availabilityZone"];
					break;
				case 12:
					cell = [[[LabelCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"DetailCell" inputOffset:77] autorelease];
					[cell setSelectionStyle:UITableViewCellSelectionStyleNone];					
					
					cell.prompt.text = @"Kernel ID";
					cell.name.text = [instance getProperty:@"kernelId"];
					break;
				case 13:
					cell = [[[LabelCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"DetailCell" inputOffset:85] autorelease];
					[cell setSelectionStyle:UITableViewCellSelectionStyleNone];					
					
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
			if ([self showTerminateButton] || [self showRebootButton]) {
				return @"Controls";
			} else {
				return @"Info";
			}
		case 1:
			if ([self showTerminateButton] || [self showRebootButton]) {
				return @"Info";
			} else {
				return nil;
			}
		default:
			return nil;
	}
}

- (void)dealloc {
	[super dealloc];
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
