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


@interface LIKEPersonalInfoViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    NSDate *currentSelectedDate;
    NSInteger pickerHeight;
    NSDateFormatter *dateFormatter;
}

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;

@property (weak, nonatomic) IBOutlet UISegmentedControl *genderSegmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *birthdayButton;
@property (weak, nonatomic) IBOutlet UIButton *privacyPolicyButton;
@property (weak, nonatomic) IBOutlet UIButton *privacyPolicyTermButton;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIView *privacyPolicyView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *betweenBirthdayAndPrivacyPolicyConstrait;
@property (weak, nonatomic) IBOutlet UIButton *avatarButton;

@property (readwrite, nonatomic, strong) LIKEUser *user;

@end

@implementation LIKEPersonalInfoViewController
#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.user = [LIKEUserContext sharedInstance].user;
    self.navigationItem.hidesBackButton = YES;
    
    [self.privacyPolicyButton setTitle:@" " forState:UIControlStateNormal];
    
    NSMutableAttributedString *privacyPolicyString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedStringFromTable(@"prompt.readPrivacyPolicy", LIKELocalizeAccount, nil)];
    [privacyPolicyString addAttribute:NSLinkAttributeName value:@" " range: NSMakeRange(7, 4)];
    self.privacyPolicyTermButton.titleLabel.attributedText = privacyPolicyString;
    
    // TODO: this block should be replace
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:NSLocalizedStringFromTable(@"format.birthdayDate", LIKELocalizeAccount, nil)];
    
    pickerHeight = CGRectGetHeight(self.datePicker.frame);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - delegate methods

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [LIKEUserContext sharedInstance].tempAvator = [info objectForKey:UIImagePickerControllerEditedImage];
    [self.avatarButton setImage:[LIKEUserContext sharedInstance].tempAvator forState:UIControlStateNormal];
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - event response

- (IBAction)uploadAvatar:(id)sender {
    PSTAlertController *choosePhotoActionSheet = [PSTAlertController actionSheetWithTitle:NSLocalizedStringFromTable(@"choose_photo", LIKELocalizeAccount, nil)];
    PSTAlertAction *actionCancel = [PSTAlertAction actionWithTitle:NSLocalizedStringFromTable(@"cancel", LIKELocalizeAccount, @"")
                                                             style:PSTAlertActionStyleCancel
                                                           handler:^(PSTAlertAction *action) {
                                                               
                                                           }];
    PSTAlertAction *actionTakePhotoFromLibrary = [PSTAlertAction actionWithTitle:NSLocalizedStringFromTable(@"take_photo_from_library", LIKELocalizeAccount, @"")
                                                                         handler:^(PSTAlertAction *action) {
                                                                             UIImagePickerControllerSourceType sourceType;
                                                                             if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                                                                                 sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                                             }
                                                                             else {
                                                                                 sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                                                                             }
                                                                             
                                                                             UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                                                                             imagePickerController.delegate = self;
                                                                             imagePickerController.allowsEditing = YES;
                                                                             imagePickerController.sourceType = sourceType;
                                                                             [self presentViewController:imagePickerController animated:YES completion:^{
                                                                                 
                                                                             }];
                                                                         }];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        PSTAlertAction *actionTakePhotoFromCamera = [PSTAlertAction actionWithTitle:NSLocalizedStringFromTable(@"take_photo_from_camera", LIKELocalizeAccount, @"")
                                                                            handler:^(PSTAlertAction *action) {
                                                                                UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                                                                                imagePickerController.delegate = self;
                                                                                imagePickerController.allowsEditing = YES;
                                                                                imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                                                [self presentViewController:imagePickerController animated:YES completion:^{
                                                                                    
                                                                                }];  
                                                                            }];
        
        [choosePhotoActionSheet addAction:actionCancel];
        [choosePhotoActionSheet addAction:actionTakePhotoFromCamera];
        [choosePhotoActionSheet addAction:actionTakePhotoFromLibrary];
    } else {
        [choosePhotoActionSheet addAction:actionCancel];
        [choosePhotoActionSheet addAction:actionTakePhotoFromLibrary];
    }
    
    [choosePhotoActionSheet showWithSender:nil controller:self animated:YES completion:^{
        
    }];
}

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
    BOOL birthdayFlag = [LIKEHelper veiryBirthday:currentSelectedDate];
    BOOL checkTermFlag = [self.privacyPolicyButton.titleLabel.text isEqualToString:@"√"];
    
    if (usernameFlag && birthdayFlag && checkTermFlag) {
        NSDictionary *keyValuePairs = @{LIKEUserNickName: self.usernameTextField.text,
                                        LIKEUserGender: @(self.genderSegmentedControl.selectedSegmentIndex? NO: YES),
                                        LIKEUserBirthday: [currentSelectedDate timeIntervalStringInMilliSecond]};
        [self showHintHudWithMessage:NSLocalizedStringFromTable(@"prompt.updating", LIKELocalizeAccount, nil)];
        [[LIKEUserContext sharedInstance] updateUserWithAvatorImage:[LIKEUserContext sharedInstance].tempAvator
                                                      keyValuePairs:keyValuePairs
                                                         completion:^(NSError *error) {
                                                               if (!error) {
                                                                   [self hideHUDWithCompletionMessage:NSLocalizedStringFromTable(@"prompt.updateProfileComplete", LIKELocalizeAccount, nil)];
                                                                   [self performSegueWithIdentifier:@"registerUnwindSegue" sender:self];
                                                               }
                                                               else {
                                                                   [self hideHUDWithCompletionMessage:NSLocalizedStringFromTable(@"error.updateProfileFail", LIKELocalizeAccount, nil)];
                                                                   NSLog(@"%@", error);
                                                               }
                                                           }];
        
        
    }
    else {
        [PSTAlertController presentDismissableAlertWithTitle:NSLocalizedStringFromTable(@"error", LIKELocalizeMain, nil)
                                                     message:NSLocalizedStringFromTable(@"fillInfomationAndCheckPrivacyPolicy", LIKELocalizeAccount, nil)
                                                  controller:self];
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
