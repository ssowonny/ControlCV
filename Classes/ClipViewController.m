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
@synthesize scrollView=m_scrollView;


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
	
	if( m_clipImage == nil )
	{
		m_scrollView.hidden = YES;
		m_textView.text = m_clipText;//[NSString stringWithFormat:@"\n\n%@", m_clipText];
		m_textView.font = DEFAULT_FONT( 18 );
		m_textView.textColor = DEFAULT_FONT_COLOR;
		m_textView.contentInset = UIEdgeInsetsMake( 40.0f, 0.0f, 0.0f, 0.0f );
	} else {
		m_textView.hidden = YES;
		m_imageView.image = m_clipImage;
		
		float fRatio = m_imageView.image.size.height / m_imageView.image.size.width;
		CGRect frame = m_imageView.frame;
		if( fRatio <= ( m_scrollView.frame.size.height / m_scrollView.frame.size.width ) )
		{
			frame.size.height = m_imageView.frame.size.width * fRatio;
			m_scrollView.contentInset = UIEdgeInsetsMake( 0.5f * ( m_scrollView.bounds.size.height - frame.size.height ), 0.0f, 0.0f, 0.0f );
		} else {
			frame.size.width = m_imageView.frame.size.height / fRatio;
			m_scrollView.contentInset = UIEdgeInsetsMake( 0.0f, 0.5f * ( m_scrollView.bounds.size.width - frame.size.width ), 0.0f, 0.0f );
		}
		m_imageView.frame = frame;
		
		m_scrollView.minimumZoomScale = 1.0f;
		m_scrollView.maximumZoomScale = 4.0f;
		m_scrollView.clipsToBounds = YES;
	}
}

- (void) scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale 
{
	scrollView.contentInset = UIEdgeInsetsMake( MAX( 0.0f, 0.5f * ( m_scrollView.bounds.size.height - view.frame.size.height ) ),
											   MAX( 0.0f, 0.5f * ( m_scrollView.bounds.size.width - view.frame.size.width ) ),
											   0.0f,
											   0.0f );
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return m_imageView;
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
