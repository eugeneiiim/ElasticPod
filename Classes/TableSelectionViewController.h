//
//  TableSelectionViewController.h
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/31/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AddAccountViewController.h"

@interface TableSelectionViewController : UITableViewController {
	UILabel* textThingToSet;
	NSArray* options;
	NSMutableString* stringToSet;
	RootViewController* rootViewController;
}

@property (nonatomic, readwrite, assign) UILabel* textThingToSet;
@property (nonatomic, readwrite, assign) NSArray* options;
@property (nonatomic, readwrite, assign) NSMutableString* stringToSet;
@property (nonatomic, readwrite, assign) RootViewController* rootViewController;

- (id)initWithStyle:(UITableViewStyle)style textThingToSet:(UILabel*)thing options:(NSArray*)opts title:(NSString*)title
		stringToSet:(NSMutableString*)stringToSet rootViewController:(RootViewController*)rvc;

@end
