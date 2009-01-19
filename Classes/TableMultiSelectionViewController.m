//
//  TableMultiSelectionViewController.m
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 1/2/09.
//  Copyright 2009 Carnegie Mellon University. All rights reserved.
//

#import "TableMultiSelectionViewController.h"
#import "CheckCell.h"

@implementation TableMultiSelectionViewController

@synthesize options, arrayToSet, textThingToSet, selected_options, rootViewController;

- (id)initWithStyle:(UITableViewStyle)style textThingToSet:(UILabel*)thing options:(NSArray*)opts
			  title:(NSString*)title arrayToSet:(NSMutableArray*)ats rootViewController:(RootViewController*)rvc {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
	if (self = [super initWithStyle:style]) {
		self.textThingToSet = thing;
		self.options = opts;
		self.title = title;
		self.arrayToSet = ats;
		self.selected_options = [[NSMutableDictionary alloc] init];
		self.rootViewController = rvc;
		
		UIBarButtonItem* save_button = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered
																	   target:self action:@selector(done:)];
		self.navigationItem.rightBarButtonItem = save_button;
		
		for (NSString* e in ats) {
			NSInteger count = 0;
			for (NSString* x in options) {
				if ([x compare:e] == NSOrderedSame) {
					[self.selected_options setValue:@"" forKey:[NSString stringWithFormat:@"%d",count]];
				}
				count++;
			}
		}
	}
	return self;
}

- (IBAction)done:(id)sender {
	[self.arrayToSet removeAllObjects];
	NSMutableString* ms = [NSMutableString stringWithString:@""];

	NSArray* keys = [selected_options allKeys];
	NSInteger count = 0;
	for (NSString* s in keys) {
		NSInteger i = [s intValue];
		[ms appendString:[options objectAtIndex:i]];
		if (count != [keys count]-1) {
			[ms appendString:@", "];
		}
		[self.arrayToSet addObject:[options objectAtIndex:i]];
		count++;
	}
	
	self.textThingToSet.text = ms;
	[self.navigationController popViewControllerAnimated:YES];
}

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

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

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.options count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"Cell";
	/*    
	 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	 if (cell == nil) {
	 cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	 }*/
    
	CheckCell* cell = [[[CheckCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	
	cell.text = [self.options objectAtIndex:indexPath.row];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;

	if ([self.selected_options valueForKey:[NSString stringWithFormat:@"%d",indexPath.row]]) {
		[cell setSelected];
	} else {
		[cell setDeselected];
	}

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString* key = [NSString stringWithFormat:@"%d",indexPath.row];
	
	if ([self.selected_options valueForKey:key] == nil) {
		[self.selected_options setValue:@"" forKey:key];
	} else {
		[self.selected_options removeObjectForKey:key];
	}
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
    [super dealloc];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[self.rootViewController updateViewForCurrentOrientation];
}

@end
