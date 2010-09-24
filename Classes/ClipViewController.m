//
//  ClipViewController.m
//  ControlCV
//
//  Created by Sungwon Lee on 10. 9. 24..
//  Copyright 2010 Seoul National Univ. All rights reserved.
//

#import "ClipViewController.h"
#import "Defines.h"

@implementation ClipViewController


@synthesize imageView=m_imageView;
@synthesize textView=m_textView;
@synthesize clipImage=m_clipImage;
@synthesize clipText=m_clipText;


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		m_clipImage = nil;
		m_clipText = nil;
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	/*
	self.view.backgroundColor = [UIColor clearColor];
	m_textView.backgroundColor = [UIColor clearColor];
	m_imageView.backgroundColor = [UIColor clearColor];
	 */
	
	BOOL bImageHidden = ( m_clipImage == nil );
	m_imageView.hidden = bImageHidden;
	m_textView.hidden = !bImageHidden;
	m_imageView.image = m_clipImage;
	m_textView.text = [NSString stringWithFormat:@"\n\n%@", m_clipText];
	m_textView.font = DEFAULT_FONT( 18 );
	m_textView.textColor = DEFAULT_FONT_COLOR;
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	self.textView = nil;
	self.imageView = nil;
	self.clipText = nil;
	self.clipImage = nil;
}


- (void)dealloc {
	[m_imageView release];
	[m_textView release];
	
	if( m_clipText )
	{
		[m_clipText release];
	}
	
	if( m_clipImage )
	{
		[m_clipImage release];
	}
	
    [super dealloc];
}


@end
