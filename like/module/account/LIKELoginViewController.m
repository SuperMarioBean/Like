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

@end

@implementation LIKELoginViewController
#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
                                                            [self hideHUDWithCompletionMessage:@"登陆成功"];
                                                            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                                                            [userDefaults setObject:self.phoneNumberTextField.text forKey:@"username"];
                                                            [userDefaults setObject:self.passwordTextField.text forKey:@"password"];
                                                            [userDefaults setObject:@(YES) forKey:@"isAutoLogin"];
                                                            [userDefaults synchronize];
                                                            
                                                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                                [self performSegueWithIdentifier:@"loginUnwindSegue" sender:self];
                                                            });
                                                        }
                                                        else {
                                                            [self hideHUDWithCompletionMessage:@"登录失败"];
                                                            NSLog(@"%@", error);
                                                        }
                                                    }];
    }
    else {
        self.passwordTextField.text = @"";
        NSString *message = @"您的电话号码或密码不正确";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitleType:UIAlertTitleError
                                                                message:message
                                                             buttonType:UIAlertButtonOk];
        
        [alertView show];
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
