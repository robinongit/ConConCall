//
//  AddNumberViewController.m
//  SimpleconfCallDialer
//
//  Created by Robin Lin on 3/19/14.
//  Copyright (c) 2014 Robin Lin. All rights reserved.
//

#import "AddNumberViewController.h"
#import "ConfCall.h"

typedef enum {
    AddNumberNickname = 0,
    AddNumberDialIn,
    AddNumberCode
} AddNumberRows;

static NSInteger NumAddNumberRows = 3;

typedef enum {
    PhoneNumberTypeUnknown,
    PhoneNumberTypeNANP, // North American Numbering Plan
} PhoneNumberType;

typedef enum {
    PhoneNumberFormatOpenParens,
    PhoneNumberFormatAreaCode,
    PhoneNumberFormatPrefix,
    PhoneNumberFormatLineNumber,
    PhoneNumberFormatNumbers
} PhoneNumberFormatPhase;

static NSString *AddNumberCellIdentifier = @"AddNumberCellIdentifier";
static NSString *PhoneNumberSeparator = @".";


@interface AddNumberViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ConfCall *confCallObj;
@property (nonatomic, assign) AddOrEdit vcType;

@end

@implementation AddNumberViewController

#pragma mark - Initialization
- (id) initWithType:(AddOrEdit)typeOfVC andconfCall:(ConfCall *)confCallToEdit {
    self = [super initWithNibName:nil bundle:nil];
    
    self.vcType = typeOfVC;
    if (self.vcType == AddVC) {
        self.confCallObj = [[ConfCall alloc] init];
    }
    else {
        self.confCallObj = confCallToEdit;
    }
    
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveconfCall:)];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationItem.leftBarButtonItem = leftButton;

    
}

- (void)viewWillLayoutSubviews {
    
    self.tableView.frame = self.view.bounds;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - selector
- (void) cancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:TRUE];
}

- (void) saveconfCall:(id)sender {
 
    [self updateconfCallObject];
    
    if ([self.confCallObj hasDialInNumber]) {
        if (self.vcType == AddVC) {
            [[SCCDCache sharedCache] setConfCallNumber:self.confCallObj];
        }
        else {
            [[SCCDCache sharedCache] editConfCallNumber:self.confCallObj atIndex:self.confCallObj.tag];
        }
        
        [self.navigationController popViewControllerAnimated:TRUE];
    }
    else {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Need a dial-in number!", nil)
                                    message:NSLocalizedString(@"There's no dial-in number entered. Please enter one before saving. Thanks!", nil)
                                   delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil)
                          otherButtonTitles:nil] show];
    }

}



#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (self.vcType == EditVC) {
        return 2;
    }
    else {
        return 1;
    }
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return NumAddNumberRows;
    }
    else {
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:AddNumberCellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AddNumberCellIdentifier];
    }
    
    
    if (indexPath.section == 0) {
    
        switch ([indexPath row]) {
            case AddNumberNickname: {
                cell.textLabel.text = @"Nickname";
                [cell.textLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
                UITextField *textField;
                if ([[cell.contentView subviews] count] > 1)
                {
                    textField = [cell.contentView.subviews objectAtIndex:1];
                }
                else
                {
                    textField = [[UITextField alloc] init];
                    textField.frame = CGRectMake(100, 10, 185, 30);
                    textField.textAlignment = NSTextAlignmentCenter;
                    textField.backgroundColor = [UIColor clearColor];
                    [cell.contentView addSubview:textField];
                }
                textField.tag = [indexPath row];
                if ([self.confCallObj isDefaultNickname]) {
                    textField.placeholder = self.confCallObj.confCallNickname;
                }
                else {
                    textField.text = self.confCallObj.confCallNickname;
                }
                break;
            }
            case AddNumberDialIn: {
                cell.textLabel.text = @"Dial-In Number";
                [cell.textLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
                UITextField *textField;
                textField.tag = [indexPath row];
                if ([[cell.contentView subviews] count] > 1)
                {
                    textField = [cell.contentView.subviews objectAtIndex:1];
                }
                else
                {
                    textField = [[UITextField alloc] init];
                    textField.frame = CGRectMake(100, 10, 185, 30);
                    textField.textAlignment = NSTextAlignmentCenter;
                    textField.backgroundColor = [UIColor clearColor];
                    textField.keyboardType = UIKeyboardTypeNumberPad;
                    [cell.contentView addSubview:textField];
                }
                textField.delegate = self;
                textField.text = self.confCallObj.confCallDialInNumber;
                break;
            }
            case AddNumberCode: {
                cell.textLabel.text = @"Passcode";
                [cell.textLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
                UITextField *textField;
                textField.tag = [indexPath row];
                if ([[cell.contentView subviews] count] > 1)
                {
                    textField = [cell.contentView.subviews objectAtIndex:1];
                }
                else
                {
                    textField = [[UITextField alloc] init];
                    textField.frame = CGRectMake(100, 10, 185, 30);
                    textField.textAlignment = NSTextAlignmentCenter;
                    textField.backgroundColor = [UIColor clearColor];
                    textField.keyboardType = UIKeyboardTypeNumberPad;
                    [cell.contentView addSubview:textField];
                }
                textField.text = self.confCallObj.confCallCode;
                break;
            }
            default: {
                break;
            }
        }
    }
    else {
        UIButton *deleteButton;
        if ([[cell.contentView subviews] count] > 1) {
            deleteButton = [cell.contentView.subviews objectAtIndex:0];
        }
        else {
            deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
            deleteButton.frame = CGRectMake(50, 10, 200, 30);
            [cell.contentView addSubview:deleteButton];
        }
        [deleteButton setTitle:@"Delete Number" forState:UIControlStateNormal];
        [deleteButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(deleteConfCall:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    switch (textField.tag) {
        case AddNumberNickname: {
            [self.confCallObj setConfCallNickname:textField.text];
            break;
        }
        case AddNumberDialIn: {
            [self.confCallObj setConfCallDialInNumber:textField.text];
            break;
        }
        case AddNumberCode: {
            [self.confCallObj setConfCallCode:textField.text];
            break;
        }
    }
    
    
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (string.length == 0) {
        return YES;
    }
    
    NSString *tempString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSMutableString *newText = [[NSMutableString alloc] init];
    unichar c;
    NSInteger digitCount = 0;
    PhoneNumberFormatPhase parserSM = PhoneNumberFormatOpenParens;
    PhoneNumberType pnType;
    
    // Phone number will look like (XXX) XXX.XXXX
    // Some notes:
    // 1. No area codes start with 0 or 1
    
    for (NSUInteger i=0; i < tempString.length; i++) {
        c = [tempString characterAtIndex:i];
        switch (parserSM) {
            case PhoneNumberFormatOpenParens: {
                if (c != '(') {
                    if (c == '1') {
                        newText = [NSMutableString stringWithFormat:@"1 ("];
                        pnType = PhoneNumberTypeNANP;
                        parserSM = PhoneNumberFormatAreaCode;
                        digitCount = 0;
                    }
                    else if (c >= '2' && c <= '9') {
                        newText = [NSMutableString stringWithFormat:@"(%c", c];
                        pnType = PhoneNumberTypeNANP;
                        parserSM = PhoneNumberFormatAreaCode;
                        digitCount = 1;
                    }
                    else {
                        newText = [NSMutableString stringWithFormat:@"%c", c];
                        pnType = PhoneNumberTypeUnknown;
                        parserSM = PhoneNumberFormatNumbers;
                    }
                }
                else {
                    newText = [NSMutableString stringWithFormat:@"%c", c];
                    pnType = PhoneNumberTypeNANP;
                    parserSM = PhoneNumberFormatAreaCode;
                }
                break;
            }
            case PhoneNumberFormatAreaCode:
            case PhoneNumberFormatPrefix:
            {
                if (digitCount == 0) {
                    if (c == '(' || c == ' ' || c == ')') {
                        newText = [NSMutableString stringWithFormat:@"%@", newText];
                    }
                    else if (c >= '2' && c <= '9') {
                        newText = [NSMutableString stringWithFormat:@"%@%c", newText, c];
                        digitCount++;
                    }
                    else {
                        // area code started with a 1 or 0 which does not exist in NANP
                        // remove the original ( and just show the numbers
                        pnType = PhoneNumberTypeUnknown;
                        parserSM = PhoneNumberFormatNumbers;
                        [newText replaceOccurrencesOfString:@"(" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [newText length])];
                        [newText replaceOccurrencesOfString:@")" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [newText length])];
                        newText = [NSMutableString stringWithFormat:@"%@%c", newText, c];
                        digitCount = 0;
                    }
                }
                else {
                    if (c >= '0' && c<= '9') {
                        newText = [NSMutableString stringWithFormat:@"%@%c", newText, c];
                    }
                    else {
                        // raise an exception
                        [NSException raise:NSInvalidArgumentException format:@"Non-numeric character entered into phone number! (%c)", c];
                    }
                    if (digitCount == 2) {
                        if (parserSM == PhoneNumberFormatAreaCode) {
                            newText = [NSMutableString stringWithFormat:@"%@) ", newText];
                            parserSM = PhoneNumberFormatPrefix;
                        }
                        else {
                            newText = [NSMutableString stringWithFormat:@"%@.", newText];
                            parserSM = PhoneNumberFormatLineNumber;
                        }
                        digitCount = 0;
                    }
                    else {
                        digitCount++;
                    }
                }
                break;
            }
            case PhoneNumberFormatLineNumber: {
                if (c == '.') {
                    newText = [NSMutableString stringWithFormat:@"%@", newText];
                }
                else if (c >= '0' && c <= '9') {
                    newText = [NSMutableString stringWithFormat:@"%@%c", newText, c];
                    if (digitCount == 3) {
                        parserSM = PhoneNumberFormatNumbers;
                        digitCount = 0;
                    }
                    else {
                        digitCount++;
                    }
                }
                else {
                    // raise an exception
                    [NSException raise:NSInvalidArgumentException format:@"Non-numeric character entered into phone number! (%c)", c];
                }
                
                break;
            }
            case PhoneNumberFormatNumbers: {
                newText = [NSMutableString stringWithFormat:@"%@%c", newText, c];
            }
        }
    }
    textField.text = newText;
    return NO;
}


#pragma mark - confCall
- (void) updateconfCallObject {
    
    for (int i=0; i < NumAddNumberRows; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        UITextField *textField = [cell.contentView.subviews objectAtIndex:1];
        switch (i) {
            case AddNumberNickname: {
                [self.confCallObj setConfCallNickname:textField.text];
                break;
            }
            case AddNumberDialIn: {
                [self.confCallObj setConfCallDialInNumber:textField.text];
                break;
            }
            case AddNumberCode: {
                [self.confCallObj setConfCallCode:textField.text];
                break;
            }
        }
    }
    
}

#pragma mark - selector
- (void) deleteConfCall:(UIButton *) sender {
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            @"Delete",
                            nil];
    
    popup.tag = sender.tag;
    [popup showInView:[UIApplication sharedApplication].keyWindow];

}

#pragma mark - UIAlertView
- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
        switch (buttonIndex)
        {
            case 0:
                [[SCCDCache sharedCache] deleteConfCallNumber:popup.tag];
                [self.navigationController popViewControllerAnimated:TRUE];
                break;
            case 1:
                NSLog(@"cancel");
                
        }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    for (UIView *subview in actionSheet.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            if ([button.currentTitle isEqualToString:@"Delete"]) {
                [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            }
        }
    }
}

#pragma mark - UIViewController
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    
    self.tableView.frame = self.view.bounds;
    
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.tableView reloadData];
}

-(NSUInteger)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskAll;
}


@end
