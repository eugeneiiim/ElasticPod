//
//  LabelCell.h
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/30/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LabelCell : UITableViewCell {
    UILabel *name;
    UILabel *prompt;
    BOOL promptMode;
	NSInteger input_offset;
}

@property (readonly, retain) UILabel *name;
@property (readonly, retain) UILabel *prompt;
@property BOOL promptMode;
@property NSInteger input_offset;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier inputOffset:(NSInteger)offset;

@end
