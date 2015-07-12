//
//  PhotoGellalryViewController.h
//  Like App
//
//  Created by Quan Changjun on 14/11/3.
//  Copyright (c) 2014年 S.K. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@protocol PhotoGellaryViewControllerProtocol <NSObject>

- (void)setImageCropWithImage:(UIImage *)image;

- (BOOL)isFireOpen;

@end

@interface PhotoGellaryViewController : UICollectionViewController
@property (nonatomic,strong) ALAssetsGroup* group;
@property (nonatomic,strong) ALAssetsLibrary* assetsLibrary;
@end
