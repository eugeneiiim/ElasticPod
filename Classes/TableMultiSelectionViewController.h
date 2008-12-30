//
//  TableMultiSelectionViewController.h
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 1/2/09.
//  Copyright 2009 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TableMultiSelectionViewController : UITableViewController {
	UILabel* textThingToSet;
	NSArray* options;
	NSMutableArray* arrayToSet;
	NSMutableDictionary* selected_options;
}

@property (nonatomic, readwrite, assign) UILabel* textThingToSet;
@property (nonatomic, readwrite, assign) NSArray* options;
@property (nonatomic, readwrite, assign) NSMutableArray* arrayToSet;
@property (nonatomic, readwrite, assign) NSMutableDictionary* selected_options;

- (id)initWithStyle:(UITableViewStyle)style textThingToSet:(UILabel*)thing options:(NSArray*)opts
			title:(NSString*)title arrayToSet:(NSMutableArray*)ats;

@end
