//
//  LIKELoginViewController.m
//  like
//
//  Created by David Fu on 6/11/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKELoginViewController.h"

@interface LIKELoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (strong, nonatomic) IBOutlet UIButton *btnLogin;

@property (strong, nonatomic) IBOutlet UIButton *btnCreateAccount;

@end

@implementation LIKELoginViewController
#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.btnCreateAccount setTintColor:BTN_COLOR];
    
    self.btnLogin.layer.masksToBounds = YES;
    self.btnLogin.layer.cornerRadius = 5;
    self.btnLogin.backgroundColor = BTN_COLOR;
    
    UIImageView* accoutn_icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"account"]];
    self.phoneNumberTextField.leftView = accoutn_icon;
    self.phoneNumberTextField.leftViewMode = UITextFieldViewModeAlways;
    
    UIImageView* password_icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"password"]];
    self.passwordTextField.leftView = password_icon;
    self.passwordTextField.leftViewMode = UITextFieldViewModeAlways;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *identifier = segue.identifier;
    if ([identifier isEqualToString:@"loginUnwindSegue"]) {
        
    }
    else if ([identifier isEqualToString:@"phoneNumberEnterSegue"]) {
        
    }
}

#pragma mark - delegate methods

#pragma mark - event response

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (IBAction)loginButtonClick:(id)sender {
    [self touchesBegan:nil withEvent:nil];

    //BOOL phoneNumberFlag = [LIKEHelper verifyPhoneNumber:self.phoneNumberTextField.text];
    BOOL phoneNumberFlag = YES;
    //BOOL passwordFlag = [LIKEHelper verifyPassword:self.passwordTextField.text];
    BOOL passwordFlag = YES;
    //BOOL debugFlag = ([self.phoneNumberTextField.text isEqualToString:self.passwordTextField.text]);
    
    [self showHUD];
    if (phoneNumberFlag && passwordFlag) {
        [[LIKEUserContext sharedInstance] loginWithPhoneNumber:self.phoneNumberTextField.text
                                                      password:self.passwordTextField.text
                                                    completion:^(NSError *error) {
                                                        if (!error) {
                                                            [self hideHUDWithCompletionMessage:NSLocalizedStringFromTable(@"prompt.loginSuccess", LIKELocalizeAccount, nil)];
                                                            
                                                            [[LIKEAppContext sharedInstance] setUsername:self.phoneNumberTextField.text];
                                                            [[LIKEAppContext sharedInstance] setPassword:self.passwordTextField.text];
                                                            [[LIKEAppContext sharedInstance] setIsAutoLogin:YES];                                                            
                                                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                                [self performSegueWithIdentifier:@"loginUnwindSegue" sender:self];
                                                            });
                                                        }
                                                        else {
                                                            [self hideHUDWithCompletionMessage:NSLocalizedStringFromTable(@"error.loginFail", LIKELocalizeAccount, nil)];
                                                            NSLog(@"%@", error);
                                                        }
                                                    }];
    }
    else {
        self.passwordTextField.text = @"";
        
        [PSTAlertController presentDismissableAlertWithTitle:NSLocalizedStringFromTable(@"error", LIKELocalizeMain, nil)
                                                     message:NSLocalizedStringFromTable(@"error.invalidPhoneNumberOrPasswordFormat", LIKELocalizeAccount, nil)
                                                  controller:self];
    }
}

- (IBAction)forgetPasswordButtonClick:(id)sender {
    [self touchesBegan:nil withEvent:nil];
    
    [LIKEUserContext sharedInstance].forgetPassword = YES;
    [self performSegueWithIdentifier:@"phoneNumberEnterSegue" sender:self];
}

- (IBAction)registerButtonClick:(id)sender {
    [self touchesBegan:nil withEvent:nil];

    [self performSegueWithIdentifier:@"phoneNumberEnterSegue" sender:self];
}

- (IBAction)loginUnwind:(UIStoryboardSegue *)unwindSegue {
    NSString *identifier = unwindSegue.identifier;
    if ([identifier isEqualToString:@"userExistUnwindSegue"]) {
        self.phoneNumberTextField.text = [LIKEUserContext sharedInstance].tempPhoneNumber;
        self.passwordTextField.text = @"";
    }
    else if ([identifier isEqualToString:@"verifyUnwindSegue"]) {
        self.phoneNumberTextField.text = [LIKEUserContext sharedInstance].tempPhoneNumber;
        self.passwordTextField.text = [LIKEUserContext sharedInstance].tempPassword;
    }
}

#pragma mark - private methods

#pragma mark - accessor methods

#pragma mark - api methods

@end
