//
//  AddNumberViewController.h
//  SimpleconfCallDialer
//
//  Created by Robin Lin on 3/19/14.
//  Copyright (c) 2014 Robin Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddNumberViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIActionSheetDelegate>

- (id) initWithType:(AddOrEdit)typeOfVC andconfCall:(ConfCall *)confCallToEdit;

@end
