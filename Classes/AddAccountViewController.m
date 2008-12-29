//
//  AddAccountViewController.m
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/19/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import "AddAccountViewController.h"
#import "AWSAccount.h"
#import "DetailCell.h"

@implementation AddAccountViewController

@synthesize accountsController, account, name_cell, access_cell, secret_cell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		UIBarButtonItem* save_button = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered
																	   target:self action:@selector(saveAccount:)];
		self.navigationItem.rightBarButtonItem = save_button;
	}
	return self;
}

- (IBAction)saveAccount:(id)sender {
	if (name_cell.name.text == nil || [name_cell.name.text length] == 0) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You must enter a name for this account." delegate:nil
											  cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else if (access_cell.name.text == nil || [access_cell.name.text length] == 0) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You must enter an access key." delegate:nil
											  cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else if (secret_cell.name.text == nil || [secret_cell.name.text length] == 0) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You must enter a secret key." delegate:nil
											  cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else {
		AWSAccount* new_acct = [AWSAccount accountWithName:name_cell.name.text accessKey:access_cell.name.text secretKey:secret_cell.name.text];
		if (account) {
			[accountsController updateAccount:self.account.name newAccount:new_acct];
		} else {
			[accountsController addAccount:new_acct];
		}
		[self.navigationController popViewControllerAnimated:YES];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
		case 0:
			return 3;
        default:
			return 0;
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[accountsController.rootViewController updateViewForCurrentOrientation];
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
			if (account) {
				cell.name.text = [account name];
			}
			cell.prompt.text = @"Name";
			self.name_cell = cell;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			break;
		case 1:
			if (account) {
				cell.name.text = [account access_key];
			}
			cell.prompt.text = @"Access key";
			self.access_cell = cell;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			break;
		case 2:
			if (account) {
				cell.name.text = [account secret_key];
			}
			cell.prompt.text = @"Secret key";
			self.secret_cell = cell;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			break;
		default:
			break;
    }

    return cell;
}

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
	self.title = NSLocalizedString(@"Add Account", @"Master view navigation title");
	[super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
}

- (void)dealloc {
    [super dealloc];
}

@end
