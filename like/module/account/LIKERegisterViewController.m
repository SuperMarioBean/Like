//
//  LIKERegisterViewController.m
//  like
//
//  Created by David Fu on 6/11/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKERegisterViewController.h"

#import <SMS_SDK/SMS_SDK.h>

@interface LIKERegisterViewController ()

@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;

@end

@implementation LIKERegisterViewController
#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - delegate methods

#pragma mark - event response

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:NO];
}

- (IBAction)nextbarButtonClick:(id)sender {
    [self touchesBegan:nil withEvent:nil];
    
    if ([LIKEHelper verifyPhoneNumber:self.phoneNumberTextField.text]) {
        __user.phoneNumber = self.phoneNumberTextField.text;
        [self performSegueWithIdentifier:@"phoneNumberVerify" sender:self];
    }
    else {
        NSString *message = @"您的电话号码不正确";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitleType:UIAlertTitleError
                                                                message:message
                                                             buttonType:UIAlertButtonOk];
        
        [alertView show];
    }
}

#pragma mark - private methods

#pragma mark - accessor methods

#pragma mark - api methods

@end
