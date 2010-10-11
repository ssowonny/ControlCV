//
//  ClipViewController.h
//  ControlCV
//
//  Created by Sungwon Lee on 10. 9. 24..
//  Copyright 2010 Seoul National Univ. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ClipViewController : UIViewController {
	UIImageView* m_imageView;
	UIWebView* m_webView;
	UITextView* m_textView;
	UIImage* m_clipImage;
	NSString* m_clipText;
	UIScrollView* m_scrollView;
}

@property (nonatomic, retain) IBOutlet UIImageView* imageView;
@property (nonatomic, retain) IBOutlet UITextView* textView;
@property (nonatomic, retain) IBOutlet UIScrollView* scrollView;
@property (nonatomic, retain) UIImage* clipImage;
@property (nonatomic, retain) NSString* clipText;

@end
