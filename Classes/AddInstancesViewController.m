//
//  AddInstancesViewController.m
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/21/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import "AddInstancesViewController.h"
#import "DetailCell.h"
#import "LabelCell.h"
#import "TableSelectionViewController.h"
#import "TableTextFieldViewController.h"
#import "TableMultiSelectionViewController.h"

@implementation AddInstancesViewController

@synthesize ec2Controller, numinstances_cell, availabilityzone_cell, imageid_cell, keyname_cell, instancetype_cell,
	input_selection, initialrefresh_avail, initialrefresh_key, model_inst, accountsController,
	ramdiskid_cell, kernelid_cell, securitygroups_cell, initialrefresh_securitygroups,
	numinstances_text, imageid_text, keyname_text, availabilityzone_text, instancetype_text,
	kernelid_text, ramdiskid_text, security_groups;

- (AddInstancesViewController*)initWithStyle:(UITableViewStyle)style ec2Controller:(EC2DataController*)ec2Ctrl
						  accountsController:(AccountsController*)accts_ctrl {
	if (self = [super initWithStyle:style]) {
		self.title = @"Run Instances";
		self.ec2Controller = ec2Ctrl;
		UIBarButtonItem* launch_button = [[UIBarButtonItem alloc] initWithTitle:@"Launch" style:UIBarButtonItemStyleBordered
																		 target:self action:@selector(runInstances:)];
		self.navigationItem.rightBarButtonItem = launch_button;

		self.input_selection = NO_SELECTION;
		self.initialrefresh_key = FALSE;
		self.initialrefresh_avail = FALSE;
		self.accountsController = accts_ctrl;
		
		self.numinstances_text = [[NSMutableString alloc] init];
		self.imageid_text = [[NSMutableString alloc] init];
		self.keyname_text = [[NSMutableString alloc] init];
		self.availabilityzone_text = [[NSMutableString alloc] init];
		self.instancetype_text = [[NSMutableString alloc] initWithString:[self.ec2Controller.instanceTypes objectAtIndex:0]];
		self.kernelid_text = [[NSMutableString alloc] init];
		self.ramdiskid_text = [[NSMutableString alloc] init];
		
		self.security_groups = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)viewDidLoad {
	[self.ec2Controller refreshAvailabilityZones];
	[self.ec2Controller refreshKeyNames];
	[self.ec2Controller refreshSecurityGroups];
}

- (IBAction)runInstances:(id)sender {
	if (self.numinstances_text == nil || [self.numinstances_text length] == 0) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Missing number of instances." delegate:nil
											  cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}

	NSInteger num_insts = [self.numinstances_text intValue];
	if (num_insts <= 0) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Number of instances must be a positive integer."
													   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else if (self.imageid_text == nil || [self.imageid_text length] == 0) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Missing image ID." delegate:nil
											  cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else if (self.keyname_text == nil || [self.keyname_text length] == 0) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Missing key name." delegate:nil
											  cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else if (self.availabilityzone_text == nil || [self.availabilityzone_text length] == 0) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Missing availability zone." delegate:nil
											  cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else if (self.instancetype_text == nil || [self.instancetype_text length] == 0) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Missing instance type." delegate:nil
											  cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else {
		self.model_inst = [[EC2Instance alloc] init];
		[self.model_inst addProperty:@"imageId" value:self.imageid_cell.name.text];
		if ([self.keyname_text compare:@"No selection"] != NSOrderedSame) {
			[self.model_inst addProperty:@"keyName" value:self.keyname_text];
		}
		if ([self.availabilityzone_text compare:@"No selection"] != NSOrderedSame) {
			[self.model_inst addProperty:@"availabilityZone" value:self.availabilityzone_text];
		}
		[self.model_inst addProperty:@"instanceType" value:self.instancetype_text];

		if ([self.kernelid_text length] > 0) {
			[self.model_inst addProperty:@"kernelId" value:self.kernelid_text];
		}
		if ([self.ramdiskid_text length] > 0) {
			[self.model_inst addProperty:@"ramdiskId" value:self.ramdiskid_text];
		}

		/*
		if ([self.securitygroups_text compare:@"No Selection"] != NSOrderedSame) {
			self.model_inst.securityGroups = [NSArray arrayWithObject:self.securitygroups_text];
		}*/
		
		self.model_inst.securityGroups = self.security_groups;
		NSString* plurality = @"";
		if (num_insts > 1) {
			plurality = @"s";
		}
		
		NSString* msg = [NSString stringWithFormat:@"Launch %d instance%@ of type %@?", num_insts, plurality,
						 [self.model_inst getProperty:@"instanceType"]];
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Confirm Launch" message:msg delegate:self
											  cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert addButtonWithTitle:@"Cancel"];
		[alert show];
		[alert release];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case 0:
			// Now actually launch the instances.
			[self.accountsController setDefaultImageIdForAccount:self.ec2Controller.account.name
				imageId:self.imageid_text];
			[self.accountsController setDefaultKernelIdForAccount:self.ec2Controller.account.name
				kernelId:self.kernelid_text];
			[self.accountsController setDefaultRamdiskIdForAccount:self.ec2Controller.account.name
				 ramdiskId:self.ramdiskid_text];
			[self.ec2Controller runInstances:self.model_inst n:[self.numinstances_text intValue]];
			break;
		case 1:
			//NSLog(@"Launch cancelled.");
			break;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 8;
		default:
			return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	LabelCell* cell;
	//DetailCell *cell = (DetailCell*)[tableView dequeueReusableCellWithIdentifier:@"DetailCell"];
	//if (cell == nil) {
		//cell.selectionStyle = UITableViewCellSelectionStyleNone;
	//}

    // Set the text in the cell for the section/row
	switch (indexPath.row) {
		case 0:
			if (self.numinstances_cell == nil) {
				cell = [[[LabelCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"DetailCell" inputOffset:145] autorelease];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;

				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.prompt.text = @"Number of instances";
				self.numinstances_cell = cell;
				cell.name.text = self.numinstances_text;
			}
			return self.numinstances_cell;
			
		case 1:
			if (self.imageid_cell == nil) {
				cell = [[[LabelCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"DetailCell" inputOffset:55] autorelease];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;

				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.prompt.text = @"AMI ID";
				
				NSString* deef = [self.accountsController getDefaultImageIdForAccount:self.ec2Controller.account.name];
				if (deef) {
					[self.imageid_text setString:[self.accountsController getDefaultImageIdForAccount:self.ec2Controller.account.name]];
				} else {
					[self.imageid_text setString:@""];
				}

				self.imageid_cell = cell;
				cell.name.text = self.imageid_text;
			}
			return self.imageid_cell;

		case 2:
			if (self.keyname_cell == nil) {
				cell = [[[LabelCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"DetailCell" inputOffset:77] autorelease];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;

				cell.prompt.text = @"Key name";
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				self.keyname_cell = cell;
				cell.name.text = self.keyname_text;
			}
			return self.keyname_cell;
				
		case 3:
			if (self.availabilityzone_cell == nil) {
				cell = [[[LabelCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"DetailCell" inputOffset:120] autorelease];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;

				cell.prompt.text = @"Availability Zone";
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				self.availabilityzone_cell = cell;
				cell.name.text = self.availabilityzone_text;
			}
			return self.availabilityzone_cell;

		case 4:
			if (self.instancetype_cell == nil) {
				cell = [[[LabelCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"DetailCell" inputOffset:103] autorelease];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;

				cell.prompt.text = @"Instance Type";
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

				self.instancetype_cell = cell;
				self.instancetype_cell.name.text = self.instancetype_text;
				cell.name.text = self.instancetype_text;
			}
			return self.instancetype_cell;

		case 5:
			if (self.securitygroups_cell == nil) {
				cell = [[[LabelCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"DetailCell" inputOffset:118] autorelease];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
				cell.prompt.text = @"Security Groups";
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				self.securitygroups_cell = cell;
				//cell.name.text = self.securitygroups_text;
			}
			return self.securitygroups_cell;

		case 6:
			if (self.kernelid_cell == nil) {
				cell = [[[LabelCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"DetailCell" inputOffset:70] autorelease];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.prompt.text = @"Kernel ID";
				
				NSString* deef = [self.accountsController getDefaultKernelIdForAccount:self.ec2Controller.account.name];
				if (deef) {
					[self.kernelid_text setString:[self.accountsController getDefaultKernelIdForAccount:self.ec2Controller.account.name]];
				} else {
					[self.kernelid_text setString:@""];
				}
				
				self.kernelid_cell = cell;
				cell.name.text = self.kernelid_text;
			}
			return self.kernelid_cell;

		case 7:
			if (self.ramdiskid_cell == nil) {
				cell = [[[LabelCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"DetailCell" inputOffset:85] autorelease];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;

				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.prompt.text = @"Ramdisk ID";

				NSString* deef = [self.accountsController getDefaultRamdiskIdForAccount:self.ec2Controller.account.name];
				if (deef) {
					[self.ramdiskid_text setString:[self.accountsController getDefaultRamdiskIdForAccount:self.ec2Controller.account.name]];
				} else {
					[self.ramdiskid_text setString:@""];
				}
				self.ramdiskid_cell = cell;
				cell.name.text = self.ramdiskid_text;
			}
			return self.ramdiskid_cell;

		default:
			return nil;
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField*)textField {
	return YES;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
    [super dealloc];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[ec2Controller.rootViewController updateViewForCurrentOrientation];
}

- (void)refreshEC2Callback:(RequestType)type {
	switch (type) {
		case DESCRIBE_KEY_PAIRS:
			if (!self.initialrefresh_key) {
				if ([self.ec2Controller.keyNames count] > 0) {
					[self.keyname_text setString:[self.ec2Controller.keyNames objectAtIndex:0]];
				} else {
					[self.keyname_text setString:@"No selection"];
				}
				self.keyname_cell.name.text = self.keyname_text;
				self.initialrefresh_key = TRUE;
			}
			break;
		case DESCRIBE_AVAILABILITY_ZONES:
			if (!self.initialrefresh_avail) {
				if ([self.ec2Controller.availabilityZones count] > 0) {
					[self.availabilityzone_text setString:[self.ec2Controller.availabilityZones objectAtIndex:0]];
				} else {
					[self.availabilityzone_text setString:@"No selection"];
				}
				self.availabilityzone_cell.name.text = self.availabilityzone_text;
				self.initialrefresh_avail = TRUE;
			}
			break;
		case DESCRIBE_SECURITY_GROUPS:
			if (!self.initialrefresh_securitygroups) {
				[self.security_groups removeAllObjects];
				NSString* txt = @"";
				if ([self.ec2Controller.securityGroups count] > 0) {
					[self.security_groups addObject:[self.ec2Controller.securityGroups objectAtIndex:0]];
					txt = [self.ec2Controller.securityGroups objectAtIndex:0];
				}

				self.securitygroups_cell.name.text = txt;
				self.initialrefresh_securitygroups = TRUE;
			}
			break;
		case RUN_INSTANCES:
			[self.navigationController popViewControllerAnimated:YES];
			break;
		default:
			break;
	}
}

-(void)refresh {
	[ec2Controller refreshInstanceData];
	[ec2Controller refreshAvailabilityZones];
	[ec2Controller refreshKeyNames];
	[ec2Controller refreshSecurityGroups];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row != 0) {
		[self.numinstances_cell.name resignFirstResponder];
	}
	if (indexPath.row != 1) {
		[self.imageid_cell.name resignFirstResponder];
	}

	TableSelectionViewController* tsvc;
	TableTextFieldViewController* ttfvc;
	TableMultiSelectionViewController* tmsvc;
	NSMutableArray* options;
	switch (indexPath.row) {
		case 0:
			ttfvc = [[TableTextFieldViewController alloc] initWithStyle:UITableViewStyleGrouped textThingToSet:self.numinstances_cell.name
																  title:@"Number of Instances" defaultText:self.numinstances_cell.name.text
														   keyboardType:UIKeyboardTypeNumberPad
															stringToSet:self.numinstances_text
													 rootViewController:self.accountsController.rootViewController];
			[self.navigationController pushViewController:ttfvc animated:YES];
			[ttfvc release];
			break;
		case 1:
			ttfvc = [[TableTextFieldViewController alloc] initWithStyle:UITableViewStyleGrouped textThingToSet:self.imageid_cell.name
																  title:@"AMI ID" defaultText:self.imageid_cell.name.text
														   keyboardType:UIKeyboardTypeASCIICapable
															stringToSet:self.imageid_text
													 rootViewController:self.accountsController.rootViewController];
			[self.navigationController pushViewController:ttfvc animated:YES];
			[ttfvc release];
			break;
		case 2:
			/*
			self.input_selection = KEYNAME_SELECTION;
			 */
			options = [[NSMutableArray alloc] initWithArray:self.ec2Controller.keyNames];
			[options addObject:@"No selection"];
			
			tsvc = [[TableSelectionViewController alloc] initWithStyle:UITableViewStyleGrouped textThingToSet:self.keyname_cell.name
															   options:options title:@"Key" stringToSet:self.keyname_text
													rootViewController:self.accountsController.rootViewController];

			[self.navigationController pushViewController:tsvc animated:YES];
			[tsvc release];
			break;
		case 3:
/*
			self.input_selection = AVAILABILITYZONE_SELECTION;
*/
			options = [[NSMutableArray alloc] initWithArray:self.ec2Controller.availabilityZones];
			[options addObject:@"No selection"];
			
			tsvc = [[TableSelectionViewController alloc] initWithStyle:UITableViewStyleGrouped textThingToSet:availabilityzone_cell.name
															   options:options title:@"Availability Zone"
														   stringToSet:self.availabilityzone_text
													rootViewController:self.accountsController.rootViewController];
			
			[self.navigationController pushViewController:tsvc animated:YES];
			[tsvc release];
			break;
		case 4:
			/*
			self.input_selection = INSTANCETYPE_SELECTION;
			 */
			
			tsvc = [[TableSelectionViewController alloc] initWithStyle:UITableViewStyleGrouped textThingToSet:instancetype_cell.name
															   options:self.ec2Controller.instanceTypes title:@"Instance Type"
														   stringToSet:self.instancetype_text
													rootViewController:self.accountsController.rootViewController];
			
			[self.navigationController pushViewController:tsvc animated:YES];
			[tsvc release];
			break;
		case 5:
			options = [[NSMutableArray alloc] initWithArray:self.ec2Controller.securityGroups];

			tmsvc = [[TableMultiSelectionViewController alloc] initWithStyle:UITableViewStyleGrouped
															  textThingToSet:securitygroups_cell.name
																	 options:options title:@"Security Groups"
																  arrayToSet:self.security_groups
														  rootViewController:self.accountsController.rootViewController];
			[self.navigationController pushViewController:tmsvc animated:YES];
			[tmsvc release];
			break;

		case 6:
			ttfvc = [[TableTextFieldViewController alloc] initWithStyle:UITableViewStyleGrouped textThingToSet:self.kernelid_cell.name
																  title:@"Kernel ID" defaultText:self.kernelid_cell.name.text
														   keyboardType:UIKeyboardTypeASCIICapable
															stringToSet:self.kernelid_text
													 rootViewController:self.accountsController.rootViewController];
			[self.navigationController pushViewController:ttfvc animated:YES];
			[ttfvc release];
			break;

		case 7:
			ttfvc = [[TableTextFieldViewController alloc] initWithStyle:UITableViewStyleGrouped textThingToSet:self.ramdiskid_cell.name
																  title:@"Ramdisk ID" defaultText:self.ramdiskid_cell.name.text
														   keyboardType:UIKeyboardTypeASCIICapable
															stringToSet:self.ramdiskid_text rootViewController:self.accountsController.rootViewController];
			[self.navigationController pushViewController:ttfvc animated:YES];
			[ttfvc release];
			break;
	}
}

- (void)viewWillAppear:(BOOL)animated {
	self.ec2Controller.rootViewController.toolbar.hidden = TRUE;
	[super viewWillAppear:animated];
}

@end
