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
    self.textLabel.text = [LIKEUserContext sharedInstance].isForgetPassword?  @"请设置您的新登录密码": @"请创建您的登录密码";
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
            // TODO: 忘记密码的流程
        }
        else {
            [self showHUD];
            [[LIKEUserContext sharedInstance] registWithPassword:self.passwordTextField.text
                                                      completion:^(NSError *error) {
                                                          [self hideHUD];
                                                          if (!error) {
                                                              [LIKEUserContext sharedInstance].tempPassword = self.passwordTextField.text;
                                                              [self performSegueWithIdentifier:@"personalInfoEnterSegue" sender:self];
                                                          }
                                                          else {
                                                              NSLog(@"%@", error);
                                                              [self showHintHudWithMessage:@"该号码已注册, 请直接登录"];
                                                              if (error.code == LIKEStatusCodeRegistUserExist) {
                                                                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                                      [self hideHUD];
                                                                      [self performSegueWithIdentifier:@"userExistUnwindSegue" sender:self];
                                                                  });
                                                              }
                                                          }
                                                      }];
        }
    }
    else {
        self.passwordTextField.text = @"";
        NSString *message = @"您输入的新密码格式不正确";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitleType:UIAlertTitleError
                                                                message:message
                                                             buttonType:UIAlertButtonOk];
        [alertView show];
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
