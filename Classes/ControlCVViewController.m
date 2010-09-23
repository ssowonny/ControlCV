//
//  ControlCVViewController.m
//  ControlCV
//
//  Created by Sungwon Lee on 10. 9. 22..
//  Copyright Seoul National Univ. 2010. All rights reserved.
//

#import "ControlCVViewController.h"
#import "ClipboardTableCell.h"

@interface ControlCVViewController( Private )

- (void)storeData;

@end


@implementation ControlCVViewController

@synthesize storage=m_storage;


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// set background clear
	self.tableView.backgroundColor = [UIColor clearColor];

	// load
	NSString *path = [[NSBundle mainBundle] bundlePath];
	NSString *filePath = [path stringByAppendingPathComponent:@"ControlCV.plist"];
	self.storage = [[[NSMutableArray alloc] initWithContentsOfFile:filePath] autorelease];
	if( self.storage == nil )
	{
		self.storage = [[[NSMutableArray alloc] init] autorelease];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	NSArray* topItem = [m_storage lastObject];
	NSString* changeCount = [NSString stringWithFormat:@"%d", [[UIPasteboard generalPasteboard] changeCount]];
	if( topItem == NULL || ![changeCount isEqualToString:[topItem objectAtIndex:2]] )
	{
	
		// copy from main pasteboard
		NSArray* items = [[UIPasteboard generalPasteboard] items];
		for( NSDictionary* item in items )
		{
			for( NSString* key in [item allKeys] )
			{
				NSString* type = nil;
				NSObject* data = nil;
				if( [key isEqualToString:@"public.jpeg"] )
				{
					UIImage* image = [item objectForKey:key];
					data = UIImageJPEGRepresentation( image, 0.8f );
					type = @"image";
				} else if( [key isEqualToString:@"public.png"] ) {
					UIImage* image = [item objectForKey:key];
					data = UIImagePNGRepresentation( image );
					type = @"image";
				} else {
					data = [item objectForKey:key];
					type = @"string";
				}
				
				// type, data, change count
				NSArray* a = [[[NSArray alloc] initWithObjects:type, data, changeCount, nil] autorelease];
				[m_storage addObject:a];
			}
		}

		// store data
		[self storeData];
		
		[self.tableView reloadData];
	}
}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.storage = nil;
}


- (void)dealloc {
	[m_storage release];
	
    [super dealloc];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// remove and store
	[m_storage removeObjectAtIndex:(m_storage.count - [indexPath row] - 1)];
	[self storeData];
	
	[self.tableView reloadData];
}


#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
	return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	//return [[[UIPasteboard generalPasteboard] pasteboardTypes] count];
	//return [m_pasteboard items].count;
	return m_storage.count;
}

- (UITableViewCell*) tableView:(UITableView*)tv
		 cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	static NSString* Identifier = @"ControlCV";
	
	ClipboardTableCell* cell = (ClipboardTableCell*)[tv dequeueReusableCellWithIdentifier:Identifier];
	if( cell == nil )
	{
		cell = [[[ClipboardTableCell alloc] initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:Identifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	// reverse order
	NSArray* item = (NSArray*)[m_storage objectAtIndex:(m_storage.count - [indexPath row] - 1)];
	NSString* type = (NSString*)[item objectAtIndex:0];
	if( [type isEqualToString:@"string"] )
	{
		cell.textLabel.text = [item objectAtIndex:1];
		cell.imageView.image = nil;
	} else {
		cell.textLabel.text = @"";
		cell.imageView.image = [UIImage imageWithData:[item objectAtIndex:1]];
	}
	
	
	
	return cell;
}

- (void)storeData
{
	// save to file
	NSString *path = [[NSBundle mainBundle] bundlePath];
	NSString *filePath = [path stringByAppendingPathComponent:@"ControlCV.plist"];
	if( ![m_storage writeToFile:filePath atomically:YES] )
	{
		NSLog( @"Fail to write." );
	}	
}

@end
