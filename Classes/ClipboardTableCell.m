//
//  ClipboardTableCell.m
//  ControlCV
//
//  Created by Sungwon Lee on 10. 9. 23..
//  Copyright 2010 Seoul National Univ. All rights reserved.
//

#import "ClipboardTableCell.h"


@implementation ClipboardTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect
{
}

- (void)dealloc {
    [super dealloc];
}


@end
