//
//  ControlCVViewController.h
//  ControlCV
//
//  Created by Sungwon Lee on 10. 9. 22..
//  Copyright Seoul National Univ. 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ControlCVViewController : UITableViewController< UITableViewDelegate, UITableViewDataSource > {
	NSMutableArray* m_storage;
}

@property (nonatomic, retain) NSMutableArray* storage;

@end

