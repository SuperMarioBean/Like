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

@property (readwrite, nonatomic, strong) LIKEUser *user;

@end

@implementation LIKELoginViewController
#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.user = [LIKEAppContext sharedInstance].user;
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

    BOOL phoneNumberFlag = [LIKEHelper verifyPhoneNumber:self.phoneNumberTextField.text];
    BOOL passwordFlag = [LIKEHelper verifyPassword:self.passwordTextField.text];
    if (phoneNumberFlag && passwordFlag) {
        self.user.phoneNumber = self.phoneNumberTextField.text;
        self.user.password = self.passwordTextField.text;
        self.user.login = YES;
        [self performSegueWithIdentifier:@"loginUnwindSegue" sender:self];
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
    
    self.user.forgetPassword = YES;
    [self performSegueWithIdentifier:@"phoneNumberEnterSegue" sender:self];
}

- (IBAction)registerButtonClick:(id)sender {
    [self touchesBegan:nil withEvent:nil];

    [self performSegueWithIdentifier:@"phoneNumberEnterSegue" sender:self];
}

- (IBAction)loginUnwind:(UIStoryboardSegue *)unwindSegue {
    self.phoneNumberTextField.text = self.user.phoneNumber;
    self.passwordTextField.text = self.user.password;
}

#pragma mark - private methods

#pragma mark - accessor methods

#pragma mark - api methods

@end
