//
//  ControlCVViewController.h
//  ControlCV
//
//  Created by Sungwon Lee on 10. 9. 22..
//  Copyright Seoul National Univ. 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ConnectionController;
@interface ControlCVViewController : UITableViewController< UITableViewDelegate, UITableViewDataSource > {
	NSMutableArray* m_storage;
	NSMutableArray* m_thumbnails;
	NSObject* m_nilObject;
	ConnectionController* m_pConnection;
}

@property (nonatomic, retain) NSMutableArray* storage;
@property (nonatomic, retain) NSMutableArray* thumbnails;
@property (nonatomic, retain) NSObject* nilObject;


- (void)mailClipTo:(id)sender;
- (void)deleteClip:(id)sender;
- (void)pasteClipTo:(id)sender;
- (void)duplicateClip:(id)sender;

@end

