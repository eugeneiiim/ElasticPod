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

@implementation InstanceGroupSetViewController

@synthesize dataController;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

- (void)viewDidLoad
{
	UIBarButtonItem* add_group_button = [[UIBarButtonItem alloc]
										 initWithTitle:@"Plus1"
										 style:UIBarButtonItemStyleBordered
										 target:self
										 action:@selector(addInstanceGroup:)];

	self.navigationItem.rightBarButtonItem = add_group_button;
	
	self.title = NSLocalizedString(@"?Account?", @"Master view navigation title");
	[super viewDidLoad];
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
  EC2InstanceGroup* itemAtIndex = (EC2InstanceGroup*)[dataController objectInListAtIndex:indexPath.row];
  cell.text = [itemAtIndex instanceGroupId];
	
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  InstanceGroupViewController* igvc = [[InstanceGroupViewController alloc] initWithStyle:UITableViewStylePlain];
  EC2InstanceGroup* grp = [[EC2InstanceGroup alloc] initWithInstanceGroupId:@"r-asdfasdf"];
  igvc.dataController = [[InstanceGroupDataController alloc] init:grp];

  [[self navigationController] pushViewController:igvc animated:YES];
  [igvc release];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
  }
  if (editingStyle == UITableViewCellEditingStyleInsert) {
  }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

/*
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
}
*/
/*
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
*/

- (IBAction)addInstanceGroup:(id)sender {
	printf("TODO go to instance group add screen");
}

- (void)dealloc {
  [super dealloc];
}

@end
