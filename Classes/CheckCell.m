//
//  CheckCell.m
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/31/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import "CheckCell.h"

@implementation CheckCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		self.accessoryType = UITableViewCellAccessoryNone;
    }
    return self;
}

- (void)setSelected {
	self.accessoryType = UITableViewCellAccessoryCheckmark;
}

- (void)setDeselected {
	self.accessoryType = UITableViewCellAccessoryNone;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	switch (self.accessoryType) {
		case UITableViewCellAccessoryCheckmark:
			[self setDeselected];
			break;
		case UITableViewCellAccessoryNone:
			[self setSelected];
			break;
	}

	[super touchesBegan:touches withEvent:event];
}

- (void)dealloc {
    [super dealloc];
}

@end
