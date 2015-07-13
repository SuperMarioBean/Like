//
//  LIKECaptureViewController.m
//  like
//
//  Created by David Fu on 7/10/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKECaptureViewController.h"

#import "PBJVision.h"
#import "PBJVisionUtilities.h"

#import <AssetsLibrary/AssetsLibrary.h>

#import "LIKETransferProcessedImageProtocol.h"

@interface LIKECaptureViewController () <PBJVisionDelegate>

@property (readwrite, nonatomic, strong) PBJVision *captureManager;

@property (weak, nonatomic) IBOutlet UIView *previewView;

@property (readwrite, nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (weak, nonatomic) IBOutlet UIButton *flashButton;

@property (weak, nonatomic) IBOutlet UIButton *imagePickerButton;

@property (readwrite, nonatomic, strong) UIImage *photoImage;

@property (readwrite, nonatomic, strong) ALAssetsLibrary *assetLibrary;

@end

@implementation LIKECaptureViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.captureManager = [PBJVision sharedInstance];
    self.assetLibrary = [[ALAssetsLibrary alloc] init];
    
    ALAssetsLibrary* assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                 usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                     if(group){
                                         [self.imagePickerButton setBackgroundImage:[UIImage imageWithCGImage:[group posterImage]]
                                                                           forState:UIControlStateNormal];
                                     }
                                 }
                               failureBlock:^(NSError *error) {
                               }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.previewLayer = [[PBJVision sharedInstance] previewLayer];
    self.previewLayer.frame = self.previewView.bounds;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.previewView.layer addSublayer:_previewLayer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self p_likeResetCapture];
    [self p_likeSetFlashButton:self.flashButton mode:PBJFlashModeAuto];
    [[PBJVision sharedInstance] startPreview];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[PBJVision sharedInstance] stopPreview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *identifier = segue.identifier;
    if ([identifier isEqualToString:@"filterSegue"]) {
        UIViewController<LIKETransferProcessedImageProtocol> *viewController = segue.destinationViewController;
        [viewController setImage:self.photoImage];
    }
    else if ([identifier isEqualToString:@"imagePickerSegue"]) {
        // TODO: transfer photo image
    }
}

#pragma mark - delegate methods

#pragma mark PBJVisionDelegate 

- (void)visionSessionWillStart:(PBJVision *)vision {

}

- (void)visionSessionDidStart:(PBJVision *)vision {

}

- (void)visionSessionDidStop:(PBJVision *)vision {

}

- (void)visionSessionWasInterrupted:(PBJVision *)vision {

}

- (void)visionSessionInterruptionEnded:(PBJVision *)vision {

}

- (void)visionCameraDeviceWillChange:(PBJVision *)vision {

}

- (void)visionCameraDeviceDidChange:(PBJVision *)vision {

}

- (void)visionCameraModeWillChange:(PBJVision *)vision {

}

- (void)visionCameraModeDidChange:(PBJVision *)vision {

}

- (void)visionOutputFormatWillChange:(PBJVision *)vision {

}

- (void)visionOutputFormatDidChange:(PBJVision *)vision {

}

- (void)vision:(PBJVision *)vision didChangeCleanAperture:(CGRect)cleanAperture {
}

- (void)visionDidChangeVideoFormatAndFrameRate:(PBJVision *)vision {

}

// focus / exposure

- (void)visionWillStartFocus:(PBJVision *)vision {

}

- (void)visionDidStopFocus:(PBJVision *)vision {

}

- (void)visionWillChangeExposure:(PBJVision *)vision {

}

- (void)visionDidChangeExposure:(PBJVision *)vision {

}

- (void)visionDidChangeFlashMode:(PBJVision *)vision {
    NSLog(@"flash mode %d", vision.flashMode);
}

- (void)visionDidChangeAuthorizationStatus:(PBJAuthorizationStatus)status {

}

- (void)visionDidChangeFlashAvailablility:(PBJVision *)vision {

}

- (void)visionSessionDidStartPreview:(PBJVision *)vision {

}

- (void)visionSessionDidStopPreview:(PBJVision *)vision {

}

// photo

- (void)visionWillCapturePhoto:(PBJVision *)vision {

}

- (void)visionDidCapturePhoto:(PBJVision *)vision {

}

- (void)vision:(PBJVision *)vision capturedPhoto:(nullable NSDictionary *)photoDict error:(nullable NSError *)error {
    if (error) {
        // handle error properly
        return;
    }
    
    NSData *photoData = photoDict[PBJVisionPhotoJPEGKey];
    NSDictionary *metadata = photoDict[PBJVisionPhotoMetadataKey];
    self.photoImage = photoDict[PBJVisionPhotoImageKey];

    __weak typeof(self) weakSelf = self;
    [self.assetLibrary writeImageDataToSavedPhotosAlbum:photoData
                                               metadata:metadata
                                        completionBlock:^(NSURL *assetURL, NSError *error1) {
                                            if (error1 || !assetURL) {
                                                // TODO: error handle
                                                return;
                                            }
                                            
                                            NSString *albumName = @"like";
                                            __block BOOL albumFound = NO;
                                            [_assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum
                                                                         usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                                                             if ([albumName compare:[group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
                                                                                 albumFound = YES;
                                                                                 [_assetLibrary assetForURL:assetURL
                                                                                                resultBlock:^(ALAsset *asset) {
                                                                                                    [group addAsset:asset];
                                                                                                    [weakSelf performSegueWithIdentifier:@"filterSegue" sender:self];
                                                                                                }
                                                                                               failureBlock:^(NSError *error) {
                                                                                                   // TODO: error handle
                                                                                               }];
                                                                             }
                                                                             if (!group && !albumFound) {
                                                                                 __weak ALAssetsLibrary *blockSafeLibrary = _assetLibrary;
                                                                                 [_assetLibrary addAssetsGroupAlbumWithName:albumName
                                                                                                                resultBlock:^(ALAssetsGroup *group1) {
                                                                                                                    [blockSafeLibrary assetForURL:assetURL
                                                                                                                                      resultBlock:^(ALAsset *asset) {
                                                                                                                                          [group1 addAsset:asset];
                                                                                                                                          [weakSelf performSegueWithIdentifier:@"filterSegue" sender:weakSelf];
                                                                                                                                      }
                                                                                                                                     failureBlock:^(NSError *error) {
                                                                                                                                         // TODO: error handle
                                                                                                                                     }];
                                                                                                                }
                                                                                                               failureBlock:^(NSError *error) {
                                                                                                                   // TODO: error handle
                                                                                                               }];
                                                                             }
                                                                         }
                                                                       failureBlock:^(NSError *error) {
                                                                           // TODO: error handle    
                                                                       }];
                                        }];
}

#pragma mark - event response

- (IBAction)closeButtonClick:(id)sender {
    [self performSegueWithIdentifier:@"captureCancelUnwind" sender:self];
}

- (IBAction)switchCameraButtonClick:(UIButton *)sender {
    self.captureManager.cameraDevice = self.captureManager.cameraDevice == PBJCameraDeviceBack ? PBJCameraDeviceFront : PBJCameraDeviceBack;
}

- (IBAction)flashButtonClick:(UIButton *)sender {
    switch (self.captureManager.flashMode) {
        case PBJFlashModeOff: {
            [self p_likeSetFlashButton:sender mode:PBJFlashModeAuto];
        }
            break;
        case PBJFlashModeOn: {
            [self p_likeSetFlashButton:sender mode:PBJFlashModeOff];
        }
            break;
        case PBJFlashModeAuto: {
            [self p_likeSetFlashButton:sender mode:PBJFlashModeOn];
        }
            break;
        default:
            break;
    }
}

- (IBAction)capturePhotoButtonClick:(id)sender {
    [self.captureManager capturePhoto];
}

- (IBAction)imagePickerButtonClick:(id)sender {
    [self performSegueWithIdentifier:@"imagePickerSegue" sender:self];
}

- (IBAction)focusTapHandler:(UITapGestureRecognizer *)sender {
    CGPoint tapPoint = [sender locationInView:_previewView];
    
    CGPoint adjustPoint = [PBJVisionUtilities convertToPointOfInterestFromViewCoordinates:tapPoint
                                                                                  inFrame:self.previewView.frame];
    [[PBJVision sharedInstance] focusExposeAndAdjustWhiteBalanceAtAdjustedPoint:adjustPoint];

}


#pragma mark - private methods

- (void)p_likeSetFlashButton:(UIButton *)flashButton mode:(PBJFlashMode)mode {
    switch (mode) {
        case PBJFlashModeOff: {
            self.captureManager.flashMode = PBJFlashModeOff;
            [flashButton setImage:[UIImage imageNamed:@"flash_off"] forState:UIControlStateNormal];
        }
            break;
        case PBJFlashModeOn: {
            self.captureManager.flashMode = PBJFlashModeOn;
            [flashButton setImage:[UIImage imageNamed:@"flash_on"] forState:UIControlStateNormal];
        }
            break;
        case PBJFlashModeAuto: {
            self.captureManager.flashMode = PBJFlashModeAuto;
            [flashButton setImage:[UIImage imageNamed:@"flash_auto"] forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
}

- (void)p_likeResetCapture {

    self.captureManager.delegate = self;
    
    if ([self.captureManager isCameraDeviceAvailable:PBJCameraDeviceBack]) {
        self.captureManager.cameraDevice = PBJCameraDeviceBack;
    } else {
        self.captureManager.cameraDevice = PBJCameraDeviceFront;
    }
    
    self.captureManager.cameraMode = PBJCameraModePhoto;
    self.captureManager.cameraOrientation = PBJCameraOrientationPortrait;
    self.captureManager.focusMode = PBJFocusModeContinuousAutoFocus;
    self.captureManager.outputFormat = PBJOutputFormatSquare;
    self.captureManager.videoRenderingEnabled = YES;
    self.captureManager.additionalCompressionProperties = @{AVVideoProfileLevelKey : AVVideoProfileLevelH264Baseline30};
}


#pragma mark - accessor methods

#pragma mark - api methods


@end
