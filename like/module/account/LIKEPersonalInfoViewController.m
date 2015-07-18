//
//  LIKEPersonalInfoViewController.m
//  like
//
//  Created by David Fu on 6/11/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKEPersonalInfoViewController.h"

static NSString *kDateCellID = @"dateCell";     // the cells with the start or end date
static NSString *kDatePickerID = @"datePicker"; // the cell containing the date picker
static NSString *kOtherCell = @"otherCell";     // the remaining cells at the end


@interface LIKEPersonalInfoViewController () {
    NSDate *currentSelectedDate;
    NSInteger pickerHeight;
    NSDateFormatter *dateFormatter;
}

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *genderSegmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *birthdayButton;
@property (weak, nonatomic) IBOutlet UIButton *privacyPolicyButton;
@property (weak, nonatomic) IBOutlet UIButton *privacyPolicyTermButton;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIView *privacyPolicyView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *betweenBirthdayAndPrivacyPolicyConstrait;

@property (readwrite, nonatomic, strong) LIKEUser *user;

@end

@implementation LIKEPersonalInfoViewController
#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.user = [LIKEAppContext sharedInstance].user;
    self.navigationItem.hidesBackButton = YES;
    
    [self.privacyPolicyButton setTitle:@" " forState:UIControlStateNormal];
    
    NSMutableAttributedString *privacyPolicyString = [[NSMutableAttributedString alloc] initWithString:@"我已阅读并同意隐私协议"];
    [privacyPolicyString addAttribute:NSLinkAttributeName value:@" " range: NSMakeRange(7, 4)];
    self.privacyPolicyTermButton.titleLabel.attributedText = privacyPolicyString;
    
    // TODO: this block should be replace
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy年 MM月 dd日"];
    
    pickerHeight = CGRectGetHeight(self.datePicker.frame);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - delegate methods

#pragma mark - event response

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [self p_lwUpdateDatepicker:self.datePicker hidden:YES];
}

- (IBAction)privacyPolicyTermClick:(id)sender {
    [self performSegueWithIdentifier:@"privacyPolicyTermSegue" sender:self];
}

- (IBAction)birthdayButtonClick:(id)sender {
    [self touchesBegan:nil withEvent:nil];
    [self p_lwUpdateDatepicker:self.datePicker hidden:!self.datePicker.hidden];
}

- (IBAction)privacyPolicyButtonClick:(id)sender {
    if ([self.privacyPolicyButton.titleLabel.text isEqualToString:@"√"]) {
        [self.privacyPolicyButton setTitle:@" " forState:UIControlStateNormal];
    }
    else {
        [self.privacyPolicyButton setTitle:@"√" forState:UIControlStateNormal];
    }
}

- (IBAction)submitBarButtonClick:(id)sender {
    [self touchesBegan:nil withEvent:nil];
    
    BOOL usernameFlag = [LIKEHelper verifyUsername:self.usernameTextField.text];
    BOOL passwordFlag = [LIKEHelper verifyPassword:self.passwordTextField.text];
    BOOL birthdayFlag = [LIKEHelper veiryBirthday:currentSelectedDate];
    BOOL checkTermFlag = [self.privacyPolicyButton.titleLabel.text isEqualToString:@"√"];
    
    if (usernameFlag && passwordFlag && birthdayFlag && checkTermFlag) {
        self.user.username = self.usernameTextField.text;
        self.user.password = self.passwordTextField.text;
        self.user.male = self.genderSegmentedControl.selectedSegmentIndex? NO: YES;
        self.user.birthday = currentSelectedDate;
        self.user.login = YES;
        [self performSegueWithIdentifier:@"registerUnwindSegue" sender:self];
    }
    else {
        NSString *message = @"请按要求填写信息并勾选隐私协议";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitleType:UIAlertTitleError
                                                                message:message
                                                             buttonType:UIAlertButtonOk];
        
        [alertView show];
    }
}

- (IBAction)personalInfoUnwind:(UIStoryboardSegue *)unwindSegue {
    NSLog(@"personal info unwind");
}


- (IBAction)dateAction:(id)sender {
    if (self.datePicker.date) {
        currentSelectedDate = self.datePicker.date;
        [self.birthdayButton setTitle: [dateFormatter stringFromDate:currentSelectedDate] forState:UIControlStateNormal];
    }
}

#pragma mark - private methods

- (void)p_lwUpdateDatepicker:(UIDatePicker *)datePicker hidden:(BOOL)hidden {
    if (datePicker.hidden == hidden) {
        return;
    }
    
    if (hidden) {
        self.birthdayButton.enabled = NO;
        [UIView animateWithDuration:0.5f animations:^{
            self.datePicker.alpha = 0.0f;
        } completion:^(BOOL finished) {
            self.datePicker.hidden = hidden;
            self.betweenBirthdayAndPrivacyPolicyConstrait.constant = self.betweenBirthdayAndPrivacyPolicyConstrait.constant - pickerHeight - 35;
            [UIView animateWithDuration:0.75f
                             animations:^{
                                 [self.view layoutIfNeeded];
                             } completion:^(BOOL finished) {
                                 self.birthdayButton.enabled = YES;
                             }];
        }];
    }
    else {
        self.birthdayButton.enabled = NO;
        self.betweenBirthdayAndPrivacyPolicyConstrait.constant = self.betweenBirthdayAndPrivacyPolicyConstrait.constant + pickerHeight + 35;
        [UIView animateWithDuration:0.75f animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.datePicker.hidden = hidden;
            [UIView animateWithDuration:0.5f
                             animations:^{
                                 self.datePicker.alpha = 1.0f;
                             } completion:^(BOOL finished) {
                                 self.birthdayButton.enabled = NO;
                             }];
        }];
    }
}

#pragma mark - accessor methods

#pragma mark - api methods

@end
