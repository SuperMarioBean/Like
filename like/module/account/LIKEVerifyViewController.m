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
    self.textLabel.text = [NSString stringWithFormat:@"%@ +%@ %@",
                           NSLocalizedStringFromTable(@"sendCodeToPhone", LIKELocalizeAccount, nil),
                           [LIKEUserContext sharedInstance].tempAreaCode,
                           [LIKEUserContext sharedInstance].tempPhoneNumber];
    
    
    self.fetchVerifyCodeButton.layer.masksToBounds = YES;
    self.fetchVerifyCodeButton.layer.cornerRadius = 5;
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
                                                                                  zone:[LIKEUserContext sharedInstance].tempAreaCode
                                                                                  code:self.verifyCodeTextField.text
                                                                            completion:^(NSError *error) {
                                                                                if (!error) {
                                                                                    [self performSegueWithIdentifier:@"setPasswordSegue" sender:self];
                                                                                }
                                                                                else {
                                                                                    [PSTAlertController presentDismissableAlertWithTitle:NSLocalizedStringFromTable(@"error", LIKELocalizeMain, nil)
                                                                                                                                 message:NSLocalizedStringFromTable(@"error.invalidSMSCodeFormat", LIKELocalizeAccount, nil)
                                                                                                                              controller:self];
                                                                                }
                                                                            }];
    }
    else {
        self.verifyCodeTextField.text = @"";
        [PSTAlertController presentDismissableAlertWithTitle:NSLocalizedStringFromTable(@"error", LIKELocalizeMain, nil)
                                                     message:NSLocalizedStringFromTable(@"error.invalidSMSCodeFormat", LIKELocalizeAccount, nil)
                                                  controller:self];
    }
}

- (IBAction)fetchVerifyCodeButtonClick:(id)sender {
    self.fetchVerifyCodeButton.enabled = NO;
    [self showHUD];
    [[LIKEUserContext sharedInstance] verificationCodeBySMSWithPhoneNumber:[LIKEUserContext sharedInstance].tempPhoneNumber
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
                                                                         [self hideHUDWithCompletionMessage:NSLocalizedStringFromTable(@"error.SMSCodeSendFail", LIKELocalizeAccount, nil)];
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
        [self.fetchVerifyCodeButton setTitle:NSLocalizedStringFromTable(@"fetchSMSCode", LIKELocalizeAccount, nil) forState:UIControlStateNormal];
        self.fetchVerifyCodeButton.enabled = YES;
        timeCount = 0;
        return;
    }
    [self.fetchVerifyCodeButton setTitle:[NSString stringWithFormat:@"%lus %@", (60 - timeCount), NSLocalizedStringFromTable(@"refetchSMSCode", LIKELocalizeAccount, nil)]
                                forState:UIControlStateDisabled];
     
}

#pragma mark - accessor methods

#pragma mark - api methods


@end
