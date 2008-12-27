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

@synthesize ec2Controller, numinstances_cell, availabilityzone_cell, imageid_cell, keyname_cell, instancetype_cell;

- (AddInstancesViewController*)initWithStyle:(UITableViewStyle)style ec2Controller:(EC2DataController*)ec2Ctrl {
	if ([super initWithStyle:style]) {
		self.title = @"Run Instances";
		self.ec2Controller = ec2Ctrl;
		UIBarButtonItem* launch_button = [[UIBarButtonItem alloc] initWithTitle:@"Launch" style:UIBarButtonItemStyleBordered
																		 target:self action:@selector(runInstances:)];
		self.navigationItem.rightBarButtonItem = launch_button;
		
		
		UIPickerView* availabilityzone_picker = [[UIPickerView alloc] init];
		[self.navigationController.view addSubview:availabilityzone_picker];
	}
	return self;
}

- (IBAction)runInstances:(id)sender {
	EC2Instance* model_inst = [[EC2Instance alloc] init];
	[model_inst addProperty:@"imageId" value:@"IMAGEID"];
	[model_inst addProperty:@"keyName" value:@"KEYNAME"];
	[model_inst addProperty:@"availabilityZone" value:@"AVAILABILITYZONE"];
	[model_inst addProperty:@"instanceType" value:@"INSTANCETYPE"];
	
	//  result = ec2.run_instances(:image_id => image_id, :min_count => n, :max_count => n, :key_name => ASDF_KEY_ID,
	//							  :availability_zone => ASDF_AVAILABILITY_ZONE, :instance_type => instance_type)
	
	//[ec2Controller runInstances:model_inst n:];
	
	[self.navigationController popViewControllerAnimated:YES];
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


    // Set the text in the cell for the section/row
	switch (indexPath.row) {
		case 0:
			cell.prompt.text = @"# instances";
			self.numinstances_cell = cell;
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

@end
