//
//  ControlCVAppDelegate.h
//  ControlCV
//
//  Created by Sungwon Lee on 10. 9. 22..
//  Copyright Seoul National Univ. 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ControlCVViewController;

@interface ControlCVAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    ControlCVViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ControlCVViewController *viewController;

@end

