//
//  ConsoleOutputViewController.h
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 2/26/09.
//  Copyright 2009 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EC2DataController.h"

@interface ConsoleOutputViewController : UIViewController {
	UITextView* textView;
	EC2DataController* ec2Controller;
	NSString* instanceGroup;
	NSString* instanceId;
}

@property (nonatomic,readwrite,retain) UITextView* textView;
@property (nonatomic,readwrite,retain) EC2DataController* ec2Controller;
@property (nonatomic,readwrite,assign) NSString* instanceGroup;
@property (nonatomic,readwrite,assign) NSString* instanceId;

- (id)initWithController:(EC2DataController*)ec2ctrl instanceId:(NSString*)instId instanceGroup:(NSString*)instanceGrp;

@end
