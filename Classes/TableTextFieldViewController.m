//
//  TableTextFieldViewController.m
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 1/1/09.
//  Copyright 2009 Carnegie Mellon University. All rights reserved.
//

#import "TableTextFieldViewController.h"
#import "LabelCell.h"

@implementation TableTextFieldViewController

@synthesize textThingToSet, field, cell, stringToSet, rootViewController;

- (id)initWithStyle:(UITableViewStyle)style textThingToSet:(UILabel*)txt title:(NSString*)tit defaultText:(NSString*)deftext
	   keyboardType:(UIKeyboardType)kbtype stringToSet:(NSMutableString*)sts rootViewController:(RootViewController*)rvc
		keyFont:(BOOL)usekeyfont {
    if (self = [super initWithStyle:style]) {
		self.rootViewController = rvc;
		self.textThingToSet = txt;
		self.title = tit;
		self.stringToSet = sts;

		UIBarButtonItem* save_button = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered
																	   target:self action:@selector(done:)];
		self.navigationItem.rightBarButtonItem = save_button;
		[save_button release];

		self.field = [[UITextField alloc] initWithFrame:CGRectZero];
		self.field.text = deftext;
		if (usekeyfont) {
			self.field.font = [UIFont fontWithName:@"Courier" size:16];
		}
		self.field.clearButtonMode = UITextFieldViewModeNever;
		self.field.adjustsFontSizeToFitWidth = YES;
		self.field.autocapitalizationType = UITextAutocapitalizationTypeNone;
		self.field.autocorrectionType = UITextAutocorrectionTypeNo;
		self.field.returnKeyType = UIReturnKeyDone;
		self.field.keyboardType = kbtype;
		self.field.delegate = self;
    }
    return self;
}

- (void)dealloc {
	[self.field release];
    [super dealloc];
}

- (IBAction)done:(id)sender {
	[self.stringToSet setString:self.field.text];
	self.textThingToSet.text = self.field.text;
	[self.navigationController popViewControllerAnimated:YES];
}

/*
- (void)viewDidLoad {
    [super viewDidLoad];
}
 */

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}*/

- (void)viewDidAppear:(BOOL)animated {
	[self resizeFieldForOrientation];
	[self.field becomeFirstResponder];
    [super viewDidAppear:animated];
}

/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

// Override to allow orientations other than the default portrait orientation.
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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[self.rootViewController updateViewForCurrentOrientation];
	[self resizeFieldForOrientation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    self.cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (self.cell == nil) {
        self.cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }

	[self resizeFieldForOrientation];

	self.cell.selectionStyle = UITableViewCellSelectionStyleNone;
	[self.cell.contentView addSubview:self.field];
	self.cell.contentView.autoresizesSubviews = YES;
	
    return cell;
}

- (void)resizeFieldForOrientation {
	CGRect rect = CGRectInset(cell.contentView.bounds, 10, 10);
	rect.size.width -= 10;
	self.field.frame = rect;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	
	[self.field becomeFirstResponder];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self done:nil];
	return TRUE;
}

@end
