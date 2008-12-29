//
//  AddInstancesViewController.m
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/21/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import "AddInstancesViewController.h"
#import "DetailCell.h"

@implementation AddInstancesViewController

@synthesize ec2Controller, numinstances_cell, availabilityzone_cell, imageid_cell, keyname_cell, instancetype_cell,
	keyname_picker, availabilityzone_picker, imageid_picker, instancetype_picker, input_selection;

- (AddInstancesViewController*)initWithStyle:(UITableViewStyle)style ec2Controller:(EC2DataController*)ec2Ctrl {
	if ([super initWithStyle:style]) {
		self.title = @"Run Instances";
		self.ec2Controller = ec2Ctrl;
		UIBarButtonItem* launch_button = [[UIBarButtonItem alloc] initWithTitle:@"Launch" style:UIBarButtonItemStyleBordered
																		 target:self action:@selector(runInstances:)];
		self.navigationItem.rightBarButtonItem = launch_button;

		self.input_selection = NO_SELECTION;



/*
		CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
		CGSize pickerSize = [keyname_picker sizeThatFits:CGSizeZero];
		CGRect pickerRect = CGRectMake(0.0, screenRect.size.height - pickerSize.height, pickerSize.width, pickerSize.height);*/
		
		keyname_picker = [[UIPickerView alloc] initWithFrame:CGRectZero];
		keyname_picker.delegate = self;
		keyname_picker.showsSelectionIndicator = YES;	// note this is default to NO
		keyname_picker.autoresizingMask = UIViewAutoresizingFlexibleWidth;

		
		availabilityzone_picker = [[UIPickerView alloc] initWithFrame:CGRectZero];
		availabilityzone_picker.delegate = self;
		availabilityzone_picker.showsSelectionIndicator = YES;	// note this is default to NO
		availabilityzone_picker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		
		/*
		[self.navigationController.view addSubview:keyname_picker];
		[self.navigationController.view bringSubviewToFront:keyname_picker];*/

/*
		CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
		CGSize pickerSize = [keyname_picker sizeThatFits:CGSizeZero];
		CGRect pickerRect = CGRectMake(	0.0, screenRect.size.height - pickerSize.height, pickerSize.width, pickerSize.height);
		
		keyname_picker = [[UIPickerView alloc] initWithFrame:CGRectZero];
		keyname_picker.frame = pickerRect;
		keyname_picker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		keyname_picker.delegate = self;
		keyname_picker.showsSelectionIndicator = YES;	// note this is default to NO
		keyname_picker.hidden = NO;
		[self.navigationController.view addSubview:keyname_picker];
		[self.navigationController.view bringSubviewToFront:keyname_picker];
*/
 
/*
		availabilityzone_picker = [[UIPickerView alloc] initWithFrame:CGRectZero];
		availabilityzone_picker.frame = pickerRect;
		availabilityzone_picker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		availabilityzone_picker.delegate = self;
		availabilityzone_picker.showsSelectionIndicator = YES;	// note this is default to NO
		availabilityzone_picker.hidden = NO;
		[self.navigationController.view addSubview:availabilityzone_picker];
		[self.navigationController.view bringSubviewToFront:availabilityzone_picker];
*/
		
		
		
		/*
		imageid_picker;
		instancetype_picker;  */

	}
	return self;
}

- (void)viewDidLoad {
	[ec2Controller refreshAvailabilityZones];
	[ec2Controller refreshKeyNames];
}

- (IBAction)runInstances:(id)sender {
	if (self.numinstances_cell.name.text == nil || [self.numinstances_cell.name.text length] == 0) {
		// TODO check that it is a number.
		
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Missing number of instances." delegate:nil
											  cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}

	NSInteger num_insts = [self.numinstances_cell.name.text intValue];
	if (num_insts <= 0) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Number of instances must be a positive integer." delegate:nil
											  cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else if (self.imageid_cell.name.text == nil || [self.imageid_cell.name.text length] == 0) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Missing image ID." delegate:nil
											  cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else if (self.keyname_cell.name.text == nil || [self.keyname_cell.name.text length] == 0) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Missing key name." delegate:nil
											  cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else if (self.availabilityzone_cell.name.text == nil || [self.availabilityzone_cell.name.text length] == 0) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Missing availability zone." delegate:nil
											  cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else if (self.instancetype_cell.name.text == nil || [self.instancetype_cell.name.text length] == 0) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Missing instance type." delegate:nil
											  cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else {
		EC2Instance* model_inst = [[EC2Instance alloc] init];
		[model_inst addProperty:@"imageId" value:@"IMAGEID"];
		[model_inst addProperty:@"keyName" value:@"KEYNAME"];
		[model_inst addProperty:@"availabilityZone" value:@"AVAILABILITYZONE"];
		[model_inst addProperty:@"instanceType" value:@"INSTANCETYPE"];

		//  result = ec2.run_instances(:image_id => image_id, :min_count => n, :max_count => n, :key_name => ASDF_KEY_ID,
		//							  :availability_zone => ASDF_AVAILABILITY_ZONE, :instance_type => instance_type)

		NSString* msg = [NSString stringWithFormat:@"Launch %d instances of type %@?", num_insts, [model_inst getProperty:@"instanceType"]];
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
			NSLog(@"LAUNCH INSTANCES");
			//[ec2Controller runInstances:model_inst n:];
			[self.navigationController popViewControllerAnimated:YES];
			break;
		case 1:
			NSLog(@"Launch cancelled.");
			break;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 5;
        default:
			return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	DetailCell *cell = (DetailCell*)[tableView dequeueReusableCellWithIdentifier:@"DetailCell"];
	if (cell == nil) {
		cell = [[[DetailCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"DetailCell"] autorelease];
		//cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	cell.selectionStyle = UITableViewCellSelectionStyleNone;

    // Set the text in the cell for the section/row
	switch (indexPath.row) {
		case 0:
			cell.prompt.text = @"# instances";
			self.numinstances_cell = cell;
			self.numinstances_cell.name.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
			break;
		case 1:
			cell.prompt.text = @"Image ID";
			self.imageid_cell = cell;
			break;
		case 2:
			cell.prompt.text = @"Key name";
			self.keyname_cell = cell;
			break;
		case 3:
			cell.prompt.text = @"Availability Zone";
			self.availabilityzone_cell = cell;
			break;
		case 4:
			cell.prompt.text = @"Instance Type";
			self.instancetype_cell = cell;
			break;
		default:
			break;
    }
	
    return cell;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
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

- (void)refreshEC2Callback {
	//NSArray* availzones = ec2Controller.availabilityZones;

	NSLog(@"listing key names");
	for (NSString* s in ec2Controller.keyNames) {
		NSLog(s);
	}
}

-(void)refresh {
	[ec2Controller refreshInstanceData];
	[ec2Controller refreshAvailabilityZones];
	[ec2Controller refreshKeyNames];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGSize pickerSize = [keyname_picker sizeThatFits:CGSizeZero];
	CGRect pickerRect = CGRectMake(0.0, screenRect.size.height - pickerSize.height, pickerSize.width, pickerSize.height);
	
	switch (indexPath.row) {
		case 0:
			break;
		case 1:
			imageid_picker.hidden = FALSE;
			break;
		case 2:

			self.input_selection = KEYNAME_SELECTION;
			
			keyname_picker.frame = pickerRect;
			keyname_picker.hidden = NO;
			
			[self.navigationController.view addSubview:keyname_picker];
			[self.navigationController.view bringSubviewToFront:keyname_picker];
			break;
		case 3:
	//		availabilityzone_picker.hidden = FALSE;

			self.input_selection = AVAILABILITYZONE_SELECTION;

			availabilityzone_picker.frame = pickerRect;
			availabilityzone_picker.hidden = NO;

			[self.navigationController.view addSubview:availabilityzone_picker];
			[self.navigationController.view bringSubviewToFront:availabilityzone_picker];
			break;
		case 4:
			instancetype_picker.hidden = FALSE;
			break;
	}
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	switch (self.input_selection) {
		case KEYNAME_SELECTION:
			return [ec2Controller.keyNames objectAtIndex:row];
		case AVAILABILITYZONE_SELECTION:
			return [ec2Controller.availabilityZones objectAtIndex:row];
	}
	return @"BLAH";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	switch (self.input_selection) {
		case KEYNAME_SELECTION:
			keyname_picker.hidden = YES;
			break;
		case AVAILABILITYZONE_SELECTION:
			availabilityzone_picker.hidden = YES;
			break;
	}
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	switch (self.input_selection) {
		case KEYNAME_SELECTION:
			return [ec2Controller.keyNames count];
		case AVAILABILITYZONE_SELECTION:
			return [ec2Controller.availabilityZones count];
	}

	return 0;
}

@end
