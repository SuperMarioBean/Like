//
//  LIKEImagePickerViewController.m
//  like
//
//  Created by David Fu on 7/10/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKEImagePickerViewController.h"

#import "LIKETransferProcessedImageProtocol.h"
#import "PhotoGellaryViewController.h"

#import "HIPImageCropperView.h"

@interface LIKEImagePickerViewController() <HIPImageCropperViewDelegate>

@property (readwrite, nonatomic, strong) HIPImageCropperView *cropperView;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGestureRecogninzer;

@property (weak, nonatomic) IBOutlet UIView *toolBarView;

@property (readwrite, nonatomic, strong) UIImage *croppedImage;

@property (weak, nonatomic) IBOutlet UIView *cropperContainerView;

@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation LIKEImagePickerViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fireOpen = NO;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (!self.cropperView) {
        self.cropperView = [[HIPImageCropperView alloc] initWithFrame:self.cropperContainerView.bounds
                                                         cropAreaSize:self.cropperContainerView.frame.size
                                                             position:HIPImageCropperViewPositionCenter];
        [self.cropperView setOriginalImage:nil];
        self.cropperView.delegate = self;
        self.cropperView.backgroundColor = [UIColor lightGrayColor];
        self.cropperView.clipsToBounds = YES;
        [self.cropperContainerView addSubview:self.cropperView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *identifier = segue.identifier;
    if ([identifier isEqualToString:@"filterSegue"]) {
        UIViewController<LIKETransferProcessedImageProtocol> *viewController = segue.destinationViewController;
        [viewController setImage:self.croppedImage];
    }
}

#pragma mark - delegate methods

#pragma mark HIPImageCropperViewDelegate

- (void)imageCropperViewDidFinishLoadingImage:(HIPImageCropperView *)cropperView {
    
}

#pragma mark PhotoGellaryViewControllerProtocol

- (void)setImageCropWithImage:(UIImage *)image {
    self.cropperView.originalImage = image;
}

#pragma mark - event response

- (IBAction)tapGestureHandler:(UITapGestureRecognizer *)sender {
    if (self.isFireOpen) {
        [self p_likeFiredListClose];
    }
    else {
        [self p_likeFiredListOpen];
    }
}

- (IBAction)confirm:(id)sender {
    self.croppedImage = self.cropperView.processedImage;
    [self performSegueWithIdentifier:@"filterSegue" sender:self];
}

#pragma mark - private methods

- (void)p_likeFiredListOpen {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [UIView animateWithDuration:.25f delay:.0f options:0 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.fireOpen = YES;
    }];
}

- (void)p_likeFiredListClose {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [UIView animateWithDuration:.25f delay:.0f options:0 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.fireOpen = NO;
    }];
}

#pragma mark - accessor methods

#pragma mark - api methods

@end
