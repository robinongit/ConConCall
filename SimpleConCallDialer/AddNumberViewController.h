//
//  AddNumberViewController.h
//  SimpleconfCallDialer
//
//  Created by Robin Lin on 3/19/14.
//
//  Copyright Robin Lin 2014.



#import <UIKit/UIKit.h>

@interface AddNumberViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIActionSheetDelegate>

- (id) initWithType:(AddOrEdit)typeOfVC andconfCall:(ConfCall *)confCallToEdit;

@end
