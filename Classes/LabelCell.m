//
//  LabelCell.m
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/30/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import "LabelCell.h"

@implementation LabelCell

@synthesize name, prompt, promptMode, input_offset;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier inputOffset:(NSInteger)offset {
	if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		self.input_offset = offset;
		
		// Initialize the labels, their fonts, colors, alignment, and background color.
		prompt = [[UILabel alloc] initWithFrame:CGRectZero];
        prompt.font = [UIFont boldSystemFontOfSize:14.0];
        prompt.textColor = [UIColor darkGrayColor];
        prompt.backgroundColor = [UIColor clearColor];

		name = [[UILabel alloc] initWithFrame:CGRectZero];
		name.font = [UIFont systemFontOfSize:16.0];
		name.backgroundColor = [UIColor clearColor];

        [self.contentView addSubview:name];
        [self.contentView addSubview:prompt];
		//self.autoresizesSubviews = YES;
    }
    return self;
}

- (void)dealloc {
	[name release];
	[prompt release];
	[super dealloc];
}

// Setting the prompt mode to YES hides the type/name labels and shows the prompt label.
- (void)setPromptMode:(BOOL)flag {
    if (flag) {
        name.hidden = YES;
        prompt.hidden = NO;
    } else {
        name.hidden = NO;
        prompt.hidden = YES;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // Start with a rect that is inset from the content view by 10 pixels on all sides.
    CGRect baseRect = CGRectInset(self.contentView.bounds, 10, 10);
    CGRect rect = baseRect;
    rect.origin.x += 10;
    // Position each label with a modified version of the base rect.
    prompt.frame = rect;
    rect.origin.x += self.input_offset;
    rect.size.width = baseRect.size.width - 110;
    name.frame = rect;
}

@end
