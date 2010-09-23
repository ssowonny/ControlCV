//
//  ClipboardTableCell.h
//  ControlCV
//
//  Created by Sungwon Lee on 10. 9. 23..
//  Copyright 2010 Seoul National Univ. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CLIP_IMAGE_FULL_WIDTH 220
#define CLIP_IMAGE_FULL_HEIGHT 60

@class ControlCVViewController;

@interface ClipboardTableCell : UITableViewCell {
	UILabel* m_firstLabel;
	UILabel* m_clipLabel;
	UIImageView* m_clipImageView;
	NSInteger m_index;
}

@property (nonatomic) NSInteger index;

- (void)setButtonAction:(ControlCVViewController*)target;
- (void)setClipText:(NSString*)text;
- (void)setClipImage:(UIImage*)image;

@end
