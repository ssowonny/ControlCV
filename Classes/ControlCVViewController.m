//
//  ControlCVViewController.m
//  ControlCV
//
//  Created by Sungwon Lee on 10. 9. 22..
//  Copyright Seoul National Univ. 2010. All rights reserved.
//

#import "ControlCVViewController.h"
#import "ClipboardTableCell.h"
#import "ClipViewController.h"
#import "ConnectionController.h"
#import "SettingViewController.h"

//type, data, change count, thumbnail
enum ITEM_CONTAINS
{
	ITEM_TYPE,
	ITEM_DATA,
	ITEM_CHANGE_COUNT,
	ITEM_THUMBNAIL,
	
	ITEM_CONTAIN_SIZE
};

@interface ControlCVViewController( Private )

- (void)storeData;
- (void)storeImage:(NSString*)filename data:(NSData*)data;
- (UIImage*)thumbnailAtIndex:(NSInteger)index;
- (UIImage*)imageWithFilename:(NSString*)filename;
- (NSString*)pathForFilename:(NSString *)filename;

@end

NSString* dateString()
{
	NSDate* date = [NSDate date];
	//NSDateFormatter* formatter = [[NSDateFormatter alloc] initWithDateFormat:@"%Y%m%d%h%M%S" allowNaturalLanguage:NO];
	NSDateFormatter* df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"yyyyMMddHHmmssSSS"];
	
	NSString* str = [df stringFromDate:date];
	[df release];
	
	return str;
}


@implementation ControlCVViewController

@synthesize storage=m_storage;
@synthesize thumbnails=m_thumbnails;
@synthesize nilObject=m_nilObject;


// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		m_pConnection = nil;
    }
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// connection
	m_pConnection = [[ConnectionController alloc] initWithDelegate:self];
	[m_pConnection start];
	
	// set background clear
	self.tableView.backgroundColor = [UIColor clearColor];
	
	// add setting button to navigation bar
	// { 
	UIButton* button = [UIButton buttonWithType:UIButtonTypeInfoDark];
	[button addTarget:self action:@selector(pushSettingView) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem* barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
	
	self.navigationItem.rightBarButtonItem = barButton;
	
	[barButton release];
	// }

	// load
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
	[self.storage removeAllObjects];
	[self.thumbnails removeAllObjects];
	
	
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
	NSString* changeCount = [NSString stringWithFormat:@"%05d", [[UIPasteboard generalPasteboard] changeCount]];
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
					
					NSString* filename = [NSString stringWithFormat:@"%@%@", dateString(), changeCount];
					[self storeImage:filename data:UIImageJPEGRepresentation( image, 0.8f )];
					data = filename;
					
					thumbnail = UIImageJPEGRepresentation( [self generateThumbnail:image], 0.8f );
					type = @"image";
				} else if( [key isEqualToString:@"public.png"] ) {
					UIImage* image = [item objectForKey:key];
					
					NSString* filename = [NSString stringWithFormat:@"%@%@", dateString(), changeCount];
					[self storeImage:filename data:UIImagePNGRepresentation( image )];
					data = filename;
					
					thumbnail = UIImagePNGRepresentation( [self generateThumbnail:image] );
					type = @"image";
				} else if( [key isEqualToString:@"public.plain-text"] || [key isEqualToString:@"public.utf8-plain-text"] ) {
					data = [item objectForKey:key];
					type = @"string";
				}
				
				if(type != nil )
				{
					// type, data/filename, change count, thumbnail
					NSArray* a = [[[NSArray alloc] initWithObjects:type, data, changeCount, thumbnail, nil] autorelease];
					[m_storage addObject:a];
					[m_thumbnails addObject:m_nilObject];
				}
			}
		}

		// store data
		[self storeData];
		
		[self.tableView reloadData];
	}
	
	// unselect selected cell
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
	
	
}

- (void)pushSettingView
{
	SettingViewController* controller = [[SettingViewController alloc] initWithNibName:@"SettingView" bundle:nil];
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
	/*
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"setting pushed" message:@"no message" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
	 */
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
	
	[m_pConnection stop];
	[m_pConnection release];
	m_pConnection = nil;
}


- (void)dealloc {
	[m_storage release];
	[m_thumbnails release];
	[m_nilObject release];
	if( m_pConnection )
	{
		[m_pConnection stop];
		[m_pConnection release];
	}
	
    [super dealloc];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

	// remove and store
	
	ClipViewController* clipViewController = [[ClipViewController alloc] initWithNibName:@"ClipView" bundle:nil];
	
	NSInteger index = (m_storage.count - [indexPath row] - 1);
	NSArray* item = [m_storage objectAtIndex:index];
	if( [@"string" isEqualToString:[item objectAtIndex:ITEM_TYPE]] )
	{
		// for text
		clipViewController.clipText = [item objectAtIndex:ITEM_DATA];
	} else {
		// for image
		NSString* filename = [item objectAtIndex:ITEM_DATA];
		clipViewController.clipImage = [self imageWithFilename:filename];//[UIImage imageWithContentsOfFile:filePath];
	}
	
	[self.navigationController pushViewController:clipViewController animated:YES];
	
	[clipViewController release];
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
		[cell setClipText:[item objectAtIndex:ITEM_DATA]];
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
	NSInteger index = cell.index;
	NSArray* item = [m_storage objectAtIndex:index];
	
	// if image, delete image file
	NSString* filename = [item objectAtIndex:ITEM_DATA];
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* documentsDirectory = [paths objectAtIndex:0];
	NSString* filePath = [documentsDirectory stringByAppendingPathComponent:filename];
	NSFileManager* fm = [NSFileManager defaultManager];
	[fm removeItemAtPath:filePath error:nil];
	
	// remove and store
	
	[m_storage removeObjectAtIndex:index];
	[m_thumbnails removeObjectAtIndex:index];
	[self storeData];
	
	[self.tableView reloadData];
}

- (void)pasteClipTo:(id)sender
{
	UIButton* btn = (UIButton*)sender;
	ClipboardTableCell* cell = (ClipboardTableCell*)btn.superview;
	
	NSInteger index = cell.index;
	NSArray* item = [m_storage objectAtIndex:index];
	if( [@"string" isEqualToString:[item objectAtIndex:ITEM_TYPE]] )
	{
		NSString* string = [NSString stringWithFormat:@"%@\r\n",[item objectAtIndex:ITEM_DATA]];
		
		int iType = 1;
		NSMutableData* data = [NSMutableData dataWithBytes:&iType length:sizeof( int )];
		[data appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
		
		//[m_pConnection writeData:data];
		[m_pConnection writeDataToAll:data];
	} else if( [@"image" isEqualToString:[item objectAtIndex:ITEM_TYPE]] ) {
		NSString* filename = (NSString*)[item objectAtIndex:ITEM_DATA];
		NSData* originalData = [NSData dataWithContentsOfFile:[self pathForFilename:filename]];
		
		int iType = 2;
		NSMutableData* data = [NSMutableData dataWithBytes:&iType length:sizeof( int )];
		[data appendData:originalData];
		
		//[m_pConnection writeData:data];
		[m_pConnection writeDataToAll:data];
	}
}

- (void)duplicateClip:(id)sender
{
	UIButton* btn = (UIButton*)sender;
	ClipboardTableCell* cell = (ClipboardTableCell*)btn.superview;
	
	NSInteger index = cell.index;
	NSArray* item = [m_storage objectAtIndex:index];
	
	NSArray* copy = [item copy];
	NSMutableArray* dup = [[NSMutableArray alloc] initWithArray:item];
	[copy release];
	
	[m_storage insertObject:dup atIndex:index];
	[m_thumbnails insertObject:m_nilObject atIndex:index];
	if( [@"image" isEqualToString:[item objectAtIndex:ITEM_TYPE]] )
	{
		// duplicate_image
		NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString* documentsDirectory = [paths objectAtIndex:0];
		NSString* filePath = [documentsDirectory stringByAppendingPathComponent:[item objectAtIndex:ITEM_DATA]];
		NSData* data = [NSData dataWithContentsOfFile:filePath];
		
		// todo : duplicate twice makes same file name
		NSString* oldFilename = (NSString*)[item objectAtIndex:ITEM_DATA];
		NSString* newFilename = [NSString stringWithFormat:@"%@%@", dateString(), [oldFilename substringFromIndex:([oldFilename length]-5)]];
		filePath = [documentsDirectory stringByAppendingPathComponent:newFilename];
		[data writeToFile:filePath atomically:YES];

		[dup replaceObjectAtIndex:ITEM_DATA withObject:newFilename];
	}
	
	[dup release];
	[self storeData];
	
	[self.tableView reloadData];
}

- (void)storeImage:(NSString*)filename data:(NSData*)data
{
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];	
    NSString* filePath = [documentsDirectory stringByAppendingPathComponent:filename];
	
	if( ![data writeToFile:filePath atomically:YES] )
	{
		NSLog( @"Fail to write image." );
	}	
}

#pragma mark -
#pragma mark ConnectionDelegate

- (void)onReadData:(NSData *)readData
{
	NSArray* item = [m_storage lastObject];
	
	NSString* type = @"string";
	NSString* changeCount = @"-1";
	if( item )
	{
		changeCount = [item objectAtIndex:ITEM_CHANGE_COUNT];
	}
	
	NSObject* thumbnail = nil;
	NSData *strData = [readData subdataWithRange:NSMakeRange(0, [readData length] - 2)];
	NSString *data = [[[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding] autorelease];
	if( data == nil )
	{
		data = [[[NSString alloc] initWithData:strData encoding:NSASCIIStringEncoding] autorelease];
	}
	
	if( data == nil )
	{
		data = [NSString stringWithFormat:@"Unkown encoding error."];
	}
	
	if(type != nil )
	{
		// type, data/filename, change count, thumbnail
		NSArray* item = [[[NSArray alloc] initWithObjects:type, data, changeCount, thumbnail, nil] autorelease];
		[m_storage addObject:item];
		[m_thumbnails addObject:m_nilObject];
	}

	// store data
	[self storeData];

	[self.tableView reloadData];
}

- (NSString*)pathForFilename:(NSString*)filename
{
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* documentsDirectory = [paths objectAtIndex:0];	
	NSString* filePath = [documentsDirectory stringByAppendingPathComponent:filename];
	
	return filePath;
}

- (UIImage*)imageWithFilename:(NSString*)filename
{
	return [UIImage imageWithContentsOfFile:[self pathForFilename:filename]];
}

@end
