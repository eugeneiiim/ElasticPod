//
//  ConsoleOutputViewController.m
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 2/26/09.
//  Copyright 2009 Carnegie Mellon University. All rights reserved.
//

#import "ConsoleOutputViewController.h"

@implementation ConsoleOutputViewController

@synthesize ec2Controller, textView, instanceId, instanceGroup;

- (id)initWithController:(EC2DataController*)ec2ctrl instanceId:(NSString*)instId instanceGroup:(NSString*)instanceGrp {
	if (self = [super init]) {
		self.ec2Controller = ec2ctrl;
		self.instanceId = instId;
		self.instanceGroup = instanceGrp;
	}
	return self;
}

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (void)dealloc {
	[self.textView release];
	
	[super dealloc];
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0,0,100,100)];
	self.textView.text = @"asdfasdfasdfasdfasdf asdasdfasdfasdf";
	self.textView.editable = false;
		//[self.view addSubview:tv];
}

- (void)refresh {
	[self.ec2Controller refreshConsoleOutput:self.instanceId group:self.instanceGroup];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[self refresh];
    [super viewDidLoad];
}

- (void)refreshEC2Callback:(RequestType)rt {
	EC2Instance* inst = [self.ec2Controller getInstance:self.instanceGroup instanceId:self.instanceId];
	self.textView.text = inst.consoleOutput;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

@end
