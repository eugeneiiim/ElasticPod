//
//  AddAccountViewController.h
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/19/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AccountsController.h"
#import "AWSAccount.h"
#import "DetailCell.h"
#import "RootViewController.h"

@interface AddAccountViewController : UITableViewController {
	AccountsController* accountsController;
	AWSAccount* account;
	DetailCell* name_cell;
	DetailCell* access_cell;
	DetailCell* secret_cell;
}

@property (nonatomic,readwrite,assign) AccountsController* accountsController;
@property (nonatomic,assign,readwrite) AWSAccount* account;
@property (nonatomic,assign,readwrite) DetailCell* name_cell;
@property (nonatomic,assign,readwrite) DetailCell* access_cell;
@property (nonatomic,assign,readwrite) DetailCell* secret_cell;

- (IBAction)saveAccount:(id)sender;

@end
