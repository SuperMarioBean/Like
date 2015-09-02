//
//  LIKEPasswordViewController.m
//  like
//
//  Created by David Fu on 8/6/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKEPasswordViewController.h"

@interface LIKEPasswordViewController ()

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation LIKEPasswordViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textLabel.text = [LIKEUserContext sharedInstance].isForgetPassword?  NSLocalizedStringFromTable(@"setNewPassword", LIKELocalizeAccount, nil): NSLocalizedStringFromTable(@"setPassword", LIKELocalizeAccount, nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - delegate methods

#pragma mark - event response

- (IBAction)nextButtonClick:(id)sender {
    [self touchesBegan:nil withEvent:nil];
    if ([LIKEHelper verifyPassword:self.passwordTextField.text]) {
        if ([LIKEUserContext sharedInstance].isForgetPassword) {
            [self showHUD];
            [[LIKEUserContext sharedInstance] changePasswordWithNewPassword:self.passwordTextField.text
                                                                 completion:^(NSError *error) {
                                                                     [self hideHUD];
                                                                     if (!error) {
                                                                         [self showHintHudWithMessage:NSLocalizedStringFromTable(@"prompt.changePassword", LIKELocalizeAccount, nil)];
                                                                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                                             [self hideHUD];
                                                                             [self performSegueWithIdentifier:@"changePasswordUnwindSegue" sender:self];
                                                                         });
                                                                     }
                                                                     else {
                                                                         [self hideHUDWithCompletionMessage:NSLocalizedStringFromTable(@"error.changePasswordFail", LIKELocalizeAccount, nil)];
                                                                     }
                                                                 }];
        }
        else {
            [self showHUD];
            [[LIKEUserContext sharedInstance] registWithPhoneNumber:[LIKEUserContext sharedInstance].tempPhoneNumber
                                                           password:self.passwordTextField.text
                                                         completion:^(NSError *error) {
                                                             [self hideHUD];
                                                             if (!error) {
                                                                 [LIKEUserContext sharedInstance].tempPassword = self.passwordTextField.text;
                                                                 [self performSegueWithIdentifier:@"personalInfoEnterSegue" sender:self];
                                                             }
                                                             else {
                                                                 NSLog(@"%@", error);
                                                                 if (error.code == LIKEStatusCodeRegistUserExist) {
                                                                     [self showHintHudWithMessage:NSLocalizedStringFromTable(@"prompt.userExist", LIKELocalizeAccount, nil)];
                                                                     
                                                                     // FIXME: 临时测试行为
                                                                     [LIKEUserContext sharedInstance].tempPassword = self.passwordTextField.text;
                                                                     [self performSegueWithIdentifier:@"personalInfoEnterSegue" sender:self];
                                                                     
                                                                     
                                                                     //                                                                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                                     //                                                                      [self hideHUD];
                                                                     //                                                                      [self performSegueWithIdentifier:@"userExistUnwindSegue" sender:self];
                                                                     //                                                                  });
                                                                 }
                                                                 else {
                                                                     [self hideHUDWithCompletionMessage:NSLocalizedStringFromTable(@"error.registFail", LIKELocalizeAccount, nil)];
                                                                 }
                                                             }
                                                         }];
        }
    }
    else {
        self.passwordTextField.text = @"";
        
        [PSTAlertController presentDismissableAlertWithTitle:NSLocalizedStringFromTable(@"error", LIKELocalizeMain, nil)
                                                     message:NSLocalizedStringFromTable(@"error.invalidPasswordFormat", LIKELocalizeAccount, nil)
                                                  controller:self];
        return;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - private methods

#pragma mark - accessor methods

#pragma mark - api methods



@end
