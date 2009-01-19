//
//  TableTextFieldViewController.h
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 1/1/09.
//  Copyright 2009 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LabelCell.h"
#import "RootViewController.h"

@interface TableTextFieldViewController : UITableViewController <UITextFieldDelegate> {
	UILabel* textThingToSet;
	UITextField* field;
	UITableViewCell* cell;
	NSMutableString* stringToSet;
	RootViewController* rootViewController;
}

@property (nonatomic,readwrite,assign) UILabel* textThingToSet;
@property (nonatomic,readwrite,assign) UITextField* field;
@property (nonatomic,readwrite,assign) UITableViewCell* cell;
@property (nonatomic,readwrite,assign) NSMutableString* stringToSet;
@property (nonatomic,readwrite,assign) RootViewController* rootViewController;

- (id)initWithStyle:(UITableViewStyle)style textThingToSet:(UILabel*)txt title:(NSString*)tit
		defaultText:(NSString*)deftext keyboardType:(UIKeyboardType)kbtype stringToSet:(NSMutableString*)stringToSet
		rootViewController:(RootViewController*)rvc keyFont:(BOOL)usekeyfont;
- (void)resizeFieldForOrientation;

@end
