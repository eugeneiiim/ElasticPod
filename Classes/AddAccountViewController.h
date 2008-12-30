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
#import "LabelCell.h"
#import "RootViewController.h"

@interface AddAccountViewController : UITableViewController {
	AccountsController* accountsController;
	AWSAccount* account;
	LabelCell* name_cell;
	LabelCell* access_cell;
	LabelCell* secret_cell;
	NSMutableString* name_text;
	NSMutableString* access_text;
	NSMutableString* secret_text;
	RootViewController* rootViewController;
}

@property (nonatomic,readwrite,assign) AccountsController* accountsController;
@property (nonatomic,assign,readwrite) AWSAccount* account;
@property (nonatomic,assign,readwrite) LabelCell* name_cell;
@property (nonatomic,assign,readwrite) LabelCell* access_cell;
@property (nonatomic,assign,readwrite) LabelCell* secret_cell;
@property (nonatomic,assign,readwrite) NSMutableString* name_text;
@property (nonatomic,assign,readwrite) NSMutableString* access_text;
@property (nonatomic,assign,readwrite) NSMutableString* secret_text;
@property (nonatomic,assign,readwrite) RootViewController* rootViewController;

- (IBAction)saveAccount:(id)sender;
- (void)refreshEC2Callback:(RequestType)rt;
- (id)initWithStyle:(UITableViewStyle)style rootViewController:(RootViewController*)rvc;

@end
