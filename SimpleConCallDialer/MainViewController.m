//
//  MainViewController.m
//  SimpleconfCallDialer
//
//  Created by Robin Lin on 3/19/14.
//
//  Copyright Robin Lin 2014.



#import "MainViewController.h"
#import "ConfCall.h"
#import "AddNumberViewController.h"

static NSString *ConfNumberCellIdentifier = @"ConfNumberCellIdentifier";

@interface MainViewController ()

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation MainViewController


#pragma mark - Initialization
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
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [self setupRightBarButton];

}

- (void) viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
    
    self.tableView.frame = self.view.bounds;
}


#pragma mark - Bar Buttons Items
- (void) setupRightBarButton {
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNumber:)];
    [self.navigationItem setRightBarButtonItem:rightButton animated:YES];
}

#pragma mark - Selectors
- (void) addNumber:(id) sender {
    AddNumberViewController *addnumber_vc = [[AddNumberViewController alloc] initWithType:AddVC andconfCall:nil];
    [self.navigationController pushViewController:addnumber_vc animated:YES];

}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *confCallArray = [[SCCDCache sharedCache] confCallNumbers];
    return [confCallArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *confCallArray = [[SCCDCache sharedCache] confCallNumbers];
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ConfNumberCellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ConfNumberCellIdentifier];
    }
    
    ConfCall *confCallObj = [confCallArray objectAtIndex:[indexPath row]];
    cell.textLabel.text = confCallObj.confCallNickname;
    cell.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    cell.tag = indexPath.row;
    
    return cell;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *confCallArray = [[SCCDCache sharedCache] confCallNumbers];
    ConfCall *confCallObj = [confCallArray objectAtIndex:[indexPath row]];
    
    NSMutableString *phoneNumber = [NSMutableString stringWithFormat:@"%@", confCallObj.confCallDialInNumber];
    // when displayed, phoneNumber has spaces and dots to make it look nicer
    // in order for the dialer to work though, they need to be taken out
    [phoneNumber replaceOccurrencesOfString:@"." withString:@"-" options:NSLiteralSearch range:NSMakeRange(0, phoneNumber.length)];
    [phoneNumber replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:NSMakeRange(0, phoneNumber.length)];
    
    NSString *dialstring = [[NSString alloc] initWithFormat:@"tel:%@,%@", phoneNumber, confCallObj.confCallCode];
    BOOL res = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:dialstring]];

    if (res == NO) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Couldn't call the number", nil)
                                    message:[NSString stringWithFormat:NSLocalizedString(@"Couldn't call the number <%@>", nil), confCallObj.confCallDialInNumber]
                                   delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil)
                          otherButtonTitles:nil] show];

    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 40.0f;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView;
    
    CGRect frame;
    
    frame = CGRectMake(0,0, 320, 40.0f); // x,y,width,height
    headerView = [[UIView alloc] initWithFrame:frame];
    
    NSString *sectionName = @"Conference Call Numbers";
    
    UIButton *sectionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    sectionButton.frame = frame; // x,y,width,height
    [sectionButton setTitle:sectionName forState:UIControlStateNormal];
    sectionButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    sectionButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [sectionButton.titleLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
    [headerView addSubview:sectionButton];
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *confCallArray = [[SCCDCache sharedCache] confCallNumbers];
    ConfCall *confCallObj = [confCallArray objectAtIndex:[indexPath row]];
    confCallObj.tag = [indexPath row];

    AddNumberViewController *addnumber_vc = [[AddNumberViewController alloc] initWithType:EditVC andconfCall:confCallObj];
    [self.navigationController pushViewController:addnumber_vc animated:YES];
    

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
