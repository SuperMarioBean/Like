//
//  LIKEVerifyViewController.m
//  like
//
//  Created by David Fu on 6/11/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKEVerifyViewController.h"

@interface LIKEVerifyViewController () {
    NSUInteger timeCount;
}

@property (weak, nonatomic) IBOutlet UITextField *verifyCodeTextField;

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@property (readwrite, nonatomic, strong) NSTimer *updateTimer;

@property (weak, nonatomic) IBOutlet UIButton *fetchVerifyCodeButton;

@end

@implementation LIKEVerifyViewController
#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textLabel.text = [NSString stringWithFormat:@"系统将会发送验证码短信到您的手机%@", [LIKEUserContext sharedInstance].tempPhoneNumber];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self fetchVerifyCodeButtonClick:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - delegate methods

#pragma mark - event response

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


- (IBAction)nextbarButtonClick:(id)sender {
    [self touchesBegan:nil withEvent:nil];
    if ([LIKEHelper verifyDigistsCode:self.verifyCodeTextField.text]) {        
        [[LIKEUserContext sharedInstance] validateVerificationCodeBySMSWithPhoneNumber:[LIKEUserContext sharedInstance].tempPhoneNumber
                                                                                  zone:@"86"
                                                                                  code:self.verifyCodeTextField.text
                                                                            completion:^(NSError *error) {
                                                                                if (!error) {
                                                                                    if ([LIKEUserContext sharedInstance].isForgetPassword) {
                                                                                        NSString *message = @"你的验证码验证成功, 你需要返回登陆界面使用新密码重新登陆一次";
                                                                                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitleType:UIAlertTitleConfirm
                                                                                                                                                message:message
                                                                                                                                             buttonType:UIAlertButtonOk
                                                                                                                                                  block:^{
                                                                                                                                                      [self performSegueWithIdentifier:@"verifyUnwindSegue" sender:self];
                                                                                                                                                  }];
                                                                                        [alertView show];
                                                                                    }
                                                                                    else {
                                                                                        [self performSegueWithIdentifier:@"setPasswordSegue" sender:self];
                                                                                    }
                                                                                }
                                                                                else {
                                                                                    NSString *message = @"您的验证码验证失败";
                                                                                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitleType:UIAlertTitleError
                                                                                                                                            message:message
                                                                                                                                         buttonType:UIAlertButtonOk];
                                                                                    
                                                                                    [alertView show];
                                                                                }
                                                                            }];
    }
    else {
        self.verifyCodeTextField.text = @"";
        NSString *message = @"您的验证码格式不正确";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitleType:UIAlertTitleError
                                                                message:message
                                                             buttonType:UIAlertButtonOk];
        [alertView show];
    }
}

- (IBAction)fetchVerifyCodeButtonClick:(id)sender {
    self.fetchVerifyCodeButton.enabled = NO;
    [self showHUD];
    [[LIKEUserContext sharedInstance] fetchVerificationCodeBySMSWithPhoneNumber:[LIKEUserContext sharedInstance].tempPhoneNumber
                                                                           zone:@"86"
                                                                     completion:^(NSError *error) {
                                                                         if (!error) {
                                                                             [self hideHUD];
                                                                             self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                                                                                                 target:self
                                                                                                                               selector:@selector(p_lwUpdateTime)
                                                                                                                               userInfo:nil
                                                                                                                                repeats:YES];
                                                                         }
                                                                         else {
                                                                             [self hideHUDWithCompletionMessage:@"您的验证码发送失败"];
                                                                             self.fetchVerifyCodeButton.enabled = YES;
                                                                         }
                                                                     }];
}

#pragma mark - private methods

- (void)p_lwUpdateTime {
    timeCount ++;
    if (timeCount >= 60) {
        [self.updateTimer invalidate];
        self.updateTimer = nil;
        [self.fetchVerifyCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        self.fetchVerifyCodeButton.enabled = YES;
        timeCount = 0;
        return;
    }
    [self.fetchVerifyCodeButton setTitle:[NSString stringWithFormat:@"%lus重新获取验证码", (60 - timeCount)]
                                forState:UIControlStateDisabled];
     
}

#pragma mark - accessor methods

#pragma mark - api methods


@end
