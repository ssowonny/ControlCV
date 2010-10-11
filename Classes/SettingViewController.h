//
//  SettingViewController.h
//  ControlCV
//
//  Created by Sungwon Lee on 10. 9. 30..
//  Copyright 2010 Seoul National Univ. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingViewController : UITableViewController< UITextFieldDelegate > {
	UITextField* m_textField;
}

@property (nonatomic, retain) IBOutlet UITextField* textField;

@end
