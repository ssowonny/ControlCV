//
//  ClipboardTableCell.m
//  ControlCV
//
//  Created by Sungwon Lee on 10. 9. 23..
//  Copyright 2010 Seoul National Univ. All rights reserved.
//

#import "ClipboardTableCell.h"
#import "ControlCVViewController.h"

@implementation ClipboardTableCell

@synthesize index=m_index;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		
		m_clipLabel = [[UILabel alloc] initWithFrame:CGRectMake( 50, 10, 180, 60 )];
		m_clipLabel.numberOfLines = 2;
		m_clipLabel.font = [UIFont fontWithName:@"American Typewriter" size:14];
		m_clipLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:m_clipLabel];
		
		m_firstLabel = [[UILabel alloc] initWithFrame:CGRectMake( 10, 10, 40, 60 )];
		m_firstLabel.font = [UIFont fontWithName:@"American Typewriter" size:40];
		m_firstLabel.backgroundColor = [UIColor clearColor];
		m_firstLabel.textAlignment = UITextAlignmentCenter;
		m_firstLabel.adjustsFontSizeToFitWidth = YES;
		[self addSubview:m_firstLabel];
		
		m_clipImageView = [[UIImageView alloc] initWithFrame:CGRectMake( 20, 10, CLIP_IMAGE_FULL_WIDTH, CLIP_IMAGE_FULL_HEIGHT )];
		[self addSubview:m_clipImageView];
		
    }
    return self;
}

- (void)setButtonAction:(ControlCVViewController*)target
{
	UIButton* pasteto = [[UIButton alloc] initWithFrame:CGRectMake( 250, 10, 29, 29 )];
	pasteto.backgroundColor = [UIColor clearColor];//[UIColor colorWithPatternImage:[UIImage imageNamed:@"pasteto.png"]];
	[pasteto setBackgroundImage:[UIImage imageNamed:@"pasteto.png"] forState:UIControlStateNormal];
	[self addSubview:pasteto];
	
	UIButton* mailto = [[UIButton alloc] initWithFrame:CGRectMake( 280, 10, 29, 29 )];
	mailto.backgroundColor = [UIColor clearColor];//[UIColor colorWithPatternImage:[UIImage imageNamed:@"pasteto.png"]];
	[mailto setBackgroundImage:[UIImage imageNamed:@"mailto.png"] forState:UIControlStateNormal]; 
	[self addSubview:mailto];
	
	UIButton* duplicate = [[UIButton alloc] initWithFrame:CGRectMake( 250, 40, 29, 29 )];
	duplicate.backgroundColor = [UIColor clearColor];//[UIColor colorWithPatternImage:[UIImage imageNamed:@"pasteto.png"]];
	[duplicate setBackgroundImage:[UIImage imageNamed:@"duplicate.png"] forState:UIControlStateNormal]; 
	[self addSubview:duplicate];
	
	UIButton* delete = [[UIButton alloc] initWithFrame:CGRectMake( 280, 40, 29, 29 )];
	delete.backgroundColor = [UIColor clearColor];//[UIColor colorWithPatternImage:[UIImage imageNamed:@"pasteto.png"]];
	[delete setBackgroundImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
	[delete addTarget:target action:@selector(deleteClip:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:delete];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	[m_clipLabel release];
	[m_firstLabel release];
	[m_clipImageView release];
	
    [super dealloc];
}

- (void)setClipText:(NSString*)text
{
	if( [text length] > 0 )
	{
		m_firstLabel.text = [text substringWithRange:NSMakeRange(0, 1)];
		m_clipLabel.text = [text substringFromIndex:1];
		
		m_firstLabel.hidden = NO;
		m_clipLabel.hidden = NO;
	} else {
		m_firstLabel.hidden = YES;
		m_clipLabel.hidden = YES;
	}
}

- (void)setClipImage:(UIImage*)image
{
	if( image == nil )
	{
		m_clipImageView.hidden = YES;
	} else {
		m_clipImageView.hidden = NO;
		m_clipImageView.image = image;		
	}
}

@end
