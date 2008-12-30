//
//  AddAccountViewController.m
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/19/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import "AddAccountViewController.h"
#import "AWSAccount.h"
#import "LabelCell.h"
#import "TableTextFieldViewController.h"

@implementation AddAccountViewController

@synthesize accountsController, account, name_cell, access_cell, secret_cell, rootViewController,
	name_text, access_text, secret_text;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		UIBarButtonItem* save_button = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered
																	   target:self action:@selector(saveAccount:)];
		self.navigationItem.rightBarButtonItem = save_button;
		[save_button release];

		self.name_text = [[NSMutableString alloc] init];
		self.access_text = [[NSMutableString alloc] init];
		self.secret_text = [[NSMutableString alloc] init];
	}
	return self;
}

- (id)initWithStyle:(UITableViewStyle)style rootViewController:(RootViewController*)rvc {
	if (self = [super initWithStyle:style]) {
		UIBarButtonItem* save_button = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered
																	   target:self action:@selector(saveAccount:)];
		self.rootViewController = rvc;
		self.navigationItem.rightBarButtonItem = save_button;
		[save_button release];
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
		if (self.account) {
			AWSAccount* new_acct = [[AWSAccount alloc] init];
			new_acct.name = [NSString stringWithString:self.name_text];
			new_acct.access_key = [NSString stringWithString:self.access_text];
			new_acct.secret_key = [NSString stringWithString:self.secret_text];
			new_acct.defaultImageId = [self.account.defaultImageId copy];
			new_acct.defaultKernelId = [self.account.defaultKernelId copy];
			new_acct.defaultRamdiskId = [self.account.defaultRamdiskId copy];
			[accountsController updateAccount:self.account.name newAccount:new_acct];
			[new_acct release];
		} else {
			AWSAccount* new_acct = [[AWSAccount alloc] initWithName:[NSString stringWithString:self.name_text]
														  accessKey:[NSString stringWithString:self.access_text]
														  secretKey:[NSString stringWithString:self.secret_text]];
			[accountsController addAccount:new_acct];
			[new_acct release];
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
	LabelCell* cell;
	//DetailCell *cell = (DetailCell*)[tableView dequeueReusableCellWithIdentifier:@"DetailCell"];
	//if (cell == nil) {
		
		//cell.selectionStyle = UITableViewCellSelectionStyleNone;
	//}

    // Set the text in the cell for the section/row
	switch (indexPath.row) {
		case 0:
			if (self.name_cell == nil) {
				cell = [[[LabelCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"DetailCell" inputOffset:50] autorelease];
				if (account) {
					cell.name.text = [account name];
				}
				cell.prompt.text = @"Name";
				self.name_cell = cell;
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				self.name_cell.name.text = self.name_text;
			}
			return self.name_cell;

		case 1:
			if (self.access_cell == nil) {
				cell = [[[LabelCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"DetailCell" inputOffset:85] autorelease];
				if (account) {
					cell.name.text = [account access_key];
				}
				cell.prompt.text = @"Access key";
				self.access_cell = cell;
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				self.access_cell.name.text = self.access_text;
			}
			return self.access_cell;

		case 2:
			if (self.secret_cell == nil) {
				cell = [[[LabelCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"DetailCell" inputOffset:81] autorelease];
				if (account) {
					cell.name.text = [account secret_key];
				}
				cell.prompt.text = @"Secret key";
				self.secret_cell = cell;
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				self.secret_cell.name.text = self.secret_text;
			}
			return self.secret_cell;

		default:
			return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	TableTextFieldViewController* ttfvc;
	
	switch(indexPath.row) {
		case 0:
			ttfvc = [[TableTextFieldViewController alloc] initWithStyle:UITableViewStyleGrouped
														 textThingToSet:self.name_cell.name
																  title:@"Account Name"
															defaultText:self.name_cell.name.text
														   keyboardType:UIKeyboardTypeASCIICapable
															stringToSet:self.name_text];
			[self.navigationController pushViewController:ttfvc animated:YES];
			[ttfvc release];
			break;
		case 1:
			ttfvc = [[TableTextFieldViewController alloc] initWithStyle:UITableViewStyleGrouped textThingToSet:self.access_cell.name
																  title:@"Access Key" defaultText:self.access_cell.name.text
														   keyboardType:UIKeyboardTypeASCIICapable stringToSet:self.access_text];
			ttfvc.field.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
			[self.navigationController pushViewController:ttfvc animated:YES];
			[ttfvc release];
			break;
		case 2:
			ttfvc = [[TableTextFieldViewController alloc] initWithStyle:UITableViewStyleGrouped textThingToSet:self.secret_cell.name
																  title:@"Secret Key" defaultText:self.secret_cell.name.text
														   keyboardType:UIKeyboardTypeASCIICapable stringToSet:self.secret_text];
			[self.navigationController pushViewController:ttfvc animated:YES];
			[ttfvc release];
			break;
	}
}

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
	self.title = NSLocalizedString(@"Add Account", @"Master view navigation title");
	[super viewDidLoad];
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
}

- (void)dealloc {
	[self.name_text release];
	[self.access_text release];
	[self.secret_text release];
    [super dealloc];
}

- (void)refreshEC2Callback:(RequestType)rt {
}

- (void)refresh {
}

- (void)add {
}

- (void)viewWillAppear:(BOOL)animated {
	self.rootViewController.toolbar.hidden = TRUE;
	[super viewWillAppear:animated];
}

/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}*/

- (void)setAccount:(AWSAccount*)acct {
	[self.name_text setString:acct.name];
	[self.access_text setString:acct.access_key];
	[self.secret_text setString:acct.secret_key];
	account = acct;
}

@end
