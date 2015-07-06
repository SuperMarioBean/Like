//
//  LIKEShareViewController.m
//  xiaomuren
//
//  Created by David Fu on 6/7/15.
//  Copyright (c) 2015 XiaoMuRen Technology. All rights reserved.
//

#import "LIKELikeViewController.h"

@interface LIKELikeViewController ()

@property (readwrite, nonatomic, strong) UITabBarController *tabBarController;

@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation LIKELikeViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - delegate methods

#pragma mark - event response

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *identifier = segue.identifier;
    if ([identifier isEqualToString:@"tabBarEmbed"]) {
        self.tabBarController = (UITabBarController *)segue.destinationViewController;
    }
}

- (IBAction)segmentedControlValueChanged:(UISegmentedControl *)sender {
    self.tabBarController.selectedIndex = sender.selectedSegmentIndex;
}

#pragma mark - private methods

#pragma mark - accessor methods

#pragma mark - api methods




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
