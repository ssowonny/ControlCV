//
//  ClipboardTableCell.h
//  ControlCV
//
//  Created by Sungwon Lee on 10. 9. 23..
//  Copyright 2010 Seoul National Univ. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ClipboardTableCell : UITableViewCell {
	UILabel* m_firstLabel;
	UILabel* m_clipLabel;
	UIImageView* m_clipImageView;
}

- (void)setClipText:(NSString*)text;
- (void)setClipImage:(UIImage*)image;

@end
