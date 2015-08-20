//
//  LIKERegisterViewController.m
//  like
//
//  Created by David Fu on 6/11/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKERegisterViewController.h"

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
        [LIKEUserContext sharedInstance].tempPhoneNumber = self.phoneNumberTextField.text;
        [self performSegueWithIdentifier:@"phoneNumberVerifySegue" sender:self];
    }
    else {
        [PSTAlertController presentDismissableAlertWithTitle:NSLocalizedStringFromTable(@"error", LIKELocalizeMain, nil)
                                                     message:NSLocalizedStringFromTable(@"error.invalidPhoneNumberFormat", LIKELocalizeAccount, nil)
                                                  controller:self];
    }
}

#pragma mark - private methods

#pragma mark - accessor methods

#pragma mark - api methods

@end
