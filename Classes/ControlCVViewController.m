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
- (UIImage*)thumbnailAtIndex:(NSInteger)index;

@end


@implementation ControlCVViewController

@synthesize storage=m_storage;
@synthesize thumbnails=m_thumbnails;
@synthesize nilObject=m_nilObject;

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
	//NSString *path = [[NSBundle mainBundle] resourcePath];
	//NSString *filePath = [path stringByAppendingPathComponent:@"ControlCV.plist"];
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* filePath = [documentsDirectory stringByAppendingPathComponent:@"clipboard.plist"];
	
	self.storage = [[[NSMutableArray alloc] initWithContentsOfFile:filePath] autorelease];
	if( self.storage == nil )
	{
		self.storage = [[[NSMutableArray alloc] init] autorelease];
	}
	
	self.thumbnails = [[[NSMutableArray alloc] init] autorelease];
	self.nilObject = [[[NSObject alloc] init] autorelease];
	for( int i = 0; i < m_storage.count; ++i )
	{
		[m_thumbnails addObject:m_nilObject];
	}
	
	// reset storage
	// [self.storage removeAllObjects];
	// [self.thumbnail removeAllObjects];
}

- (UIImage*)generateThumbnail:(UIImage*)image
{
	CGSize targetSize = CGSizeMake( CLIP_IMAGE_FULL_WIDTH, CLIP_IMAGE_FULL_HEIGHT );
	CGSize imageSize = image.size;
	CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
	float fScaledWidth = targetSize.width;
	float fScaledHeight = targetSize.height;
	
	if (CGSizeEqualToSize(imageSize, targetSize) == NO) 
	{
		// scale factor => width
		float fScale = targetSize.width / imageSize.width;
		fScaledWidth = imageSize.width * fScale;
		fScaledHeight = imageSize.height * fScale;
		
        // center the image
		thumbnailPoint.y = (targetSize.height - fScaledHeight) * 0.5;
	}       
	
	UIGraphicsBeginImageContext(targetSize); // this will crop
	
	CGRect thumbnailRect = CGRectZero;
	thumbnailRect.origin = thumbnailPoint;
	thumbnailRect.size.width = fScaledWidth;
	thumbnailRect.size.height = fScaledHeight;
	
	[image drawInRect:thumbnailRect];
	
	UIImage* thumbnail = UIGraphicsGetImageFromCurrentImageContext();
	if(thumbnail == nil) 
        NSLog(@"could not scale image");
	
	//pop the context to get back to the default
	UIGraphicsEndImageContext();
	
	return thumbnail;
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
				NSObject* thumbnail = nil;
				if( [key isEqualToString:@"public.jpeg"] )
				{
					UIImage* image = [item objectForKey:key];
					data = UIImageJPEGRepresentation( image, 0.8f );
					thumbnail = UIImageJPEGRepresentation( [self generateThumbnail:image], 0.8f );
					type = @"image";
				} else if( [key isEqualToString:@"public.png"] ) {
					UIImage* image = [item objectForKey:key];
					data = UIImagePNGRepresentation( image );
					thumbnail = UIImagePNGRepresentation( [self generateThumbnail:image] );
					type = @"image";
				} else if( [key isEqualToString:@"public.plain-text"] || [key isEqualToString:@"public.utf8-plain-text"] ) {
					data = [item objectForKey:key];
					type = @"string";
				}
				
				if(type != nil )
				{
					// type, data, change count, thumbnail
					NSArray* a = [[[NSArray alloc] initWithObjects:type, data, changeCount, thumbnail, nil] autorelease];
					[m_storage addObject:a];
				}
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
	self.thumbnails = nil;
	self.nilObject = nil;
}


- (void)dealloc {
	[m_storage release];
	[m_thumbnails release];
	[m_nilObject release];
	
    [super dealloc];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	/*
	// remove and store
	NSInteger index = (m_storage.count - [indexPath row] - 1);
	[m_storage removeObjectAtIndex:index];
	[m_thumbnails removeObjectAtIndex:index];
	[self storeData];
	
	[self.tableView reloadData];
	 */
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 80;
}

- (UITableViewCell*) tableView:(UITableView*)tv
		 cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	static NSString* Identifier = @"ControlCV";
	
	ClipboardTableCell* cell = (ClipboardTableCell*)[tv dequeueReusableCellWithIdentifier:Identifier];
	if( cell == nil )
	{
		cell = [[[ClipboardTableCell alloc] initWithFrame:CGRectMake( 0, 0, 0, 0 )
									   reuseIdentifier:Identifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
		[cell setButtonAction:self];
	}
	
	// reverse order
	NSInteger index = (m_storage.count - [indexPath row] - 1);
	NSArray* item = (NSArray*)[m_storage objectAtIndex:index];
	NSString* type = (NSString*)[item objectAtIndex:0];
	if( [type isEqualToString:@"string"] )
	{
		//cell.clipLabel.text = [item objectAtIndex:1];
		[cell setClipText:[item objectAtIndex:1]];
		[cell setClipImage:nil];
	} else {
		//cell.clipLabel.text = @"";
		[cell setClipText:@""];
		[cell setClipImage:[self thumbnailAtIndex:index]];
	}
	cell.index = index;
	
	return cell;
}

- (void)storeData
{
	// save to file
	//NSString *path = [[NSBundle mainBundle] resourcePath];
	//NSString *filePath = [path stringByAppendingPathComponent:@"ControlCV.plist"];
	
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];	
    NSString* filePath = [documentsDirectory stringByAppendingPathComponent:@"clipboard.plist"];
	
	if( ![m_storage writeToFile:filePath atomically:YES] )
	{
		NSLog( @"Fail to write." );
	}	
}

- (UIImage*)thumbnailAtIndex:(NSInteger)index
{
	UIImage* thumbnail = [m_thumbnails objectAtIndex:index];
	if( thumbnail == m_nilObject )
	{
		NSArray* item = (NSArray*)[m_storage objectAtIndex:index];
		thumbnail = [UIImage imageWithData:[item objectAtIndex:3]];
		[m_thumbnails replaceObjectAtIndex:index withObject:thumbnail];
	}
	
	return thumbnail;
}

#pragma mark -
#pragma mark Button actions from cell

- (void)mailClipTo:(id)sender
{
}

- (void)deleteClip:(id)sender
{
	UIButton* btn = (UIButton*)sender;
	ClipboardTableCell* cell = (ClipboardTableCell*)btn.superview;
	
	// remove and store
	NSInteger index = cell.index;
	[m_storage removeObjectAtIndex:index];
	[m_thumbnails removeObjectAtIndex:index];
	[self storeData];
	
	[self.tableView reloadData];
}

- (void)pasteClipTo:(id)sender
{
}

- (void)duplicateClip:(id)sender
{
}

@end
