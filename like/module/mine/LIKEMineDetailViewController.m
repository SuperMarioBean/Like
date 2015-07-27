//
//  LIKEMineDetailViewController.m
//  like
//
//  Created by David Fu on 7/27/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKEMineDetailViewController.h"
#import "LIKEMineDetailViewModel.h"

@interface LIKEMineDetailViewController () <UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (readwrite, nonatomic, strong) LIKEMineDetailViewModel *viewModel;

@end

@implementation LIKEMineDetailViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.viewModel = [[LIKEMineDetailViewModel alloc] init];
    
    self.collectionView.dataSource = self.viewModel;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"LIKEMineTrendItem" bundle:nil]
          forCellWithReuseIdentifier:LIKEMineItemTrendCellIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:@"LIKEMinePhotoItem" bundle:nil]
          forCellWithReuseIdentifier:LIKEMineItemPhotoCellIdentifier];
//    [self.collectionView registerNib:[UINib nibWithNibName:@"LIKEMineWantItem" bundle:nil]
//          forCellWithReuseIdentifier:LIKEMineItemWantCellIdentifier];
//    [self.collectionView registerNib:[UINib nibWithNibName:@"LIKEMineDinnerItem" bundle:nil]
//          forCellWithReuseIdentifier:LIKEMineItemDinnerCellIdentifier];
//    [self.collectionView registerNib:[UINib nibWithNibName:@"LIKEMineQuestionItem" bundle:nil]
//          forCellWithReuseIdentifier:LIKEMineItemQuestionCellIdentifier];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"LIKEMineDetailHeaderView" bundle:nil]
          forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                 withReuseIdentifier:LIKEMineItemDetailHeaderIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:@"LIKEMineStatisticsHeaderView" bundle:nil]
          forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                 withReuseIdentifier:LIKEMineItemStatisticsHeaderIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.collectionView.contentInset = UIEdgeInsetsMake(CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + CGRectGetHeight(self.navigationController.navigationBar.frame) , 0, CGRectGetHeight(self.tabBarController.tabBar.frame), 0);
    self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset;
}

#pragma mark - delegate methods

#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellKind = [self.viewModel cellKindForIndexPath:indexPath];
    if ([cellKind isEqualToString:LIKEMineItemElementKindCellTrend]) {
        return CGSizeMake(CGRectGetWidth(collectionView.frame), 80.0f);
    }
    switch (self.viewModel.itemType) {
        case LIKEMineItemTypePhotos: {
            CGFloat width = floorf((CGRectGetWidth(self.collectionView.frame) - 4 * 4) / 3);
            return CGSizeMake(width, width);
        }
            break;
        case LIKEMineItemTypeWants: {
        // TODO
        }
            break;
        case LIKEMineItemTypeDinners: {
        // TODO
        }
            break;
        case LIKEMineItemTypeQuestions: {
        // TODO
        }
            break;
        default:
            break;
    }
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
    NSString *headerKind = [self.viewModel headerKindForSection:section];
    if ([headerKind isEqualToString:LIKEMineItemElementKindHeaderDetail]) {
        return CGSizeMake(CGRectGetWidth(self.collectionView.frame), CGRectGetWidth(self.collectionView.frame) * 2 / 3 + 90.0f);
    }
    else if ([headerKind isEqualToString:LIKEMineItemElementKindHeaderStatistics]) {
        return CGSizeMake(CGRectGetWidth(self.collectionView.frame), 50.0f);
    }
    return CGSizeZero;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    NSString *headerKind = [self.viewModel headerKindForSection:section];
    if ([headerKind isEqualToString:LIKEMineItemElementKindHeaderStatistics]) {
        return  UIEdgeInsetsMake(4, 4, 4, 4);
    }
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    NSString *headerKind = [self.viewModel headerKindForSection:section];
    if ([headerKind isEqualToString:LIKEMineItemElementKindHeaderStatistics]) {
        return 4.0f;
    }
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    NSString *headerKind = [self.viewModel headerKindForSection:section];
    if ([headerKind isEqualToString:LIKEMineItemElementKindHeaderStatistics]) {
        return 4.0f;
    }
    return 0.0f;
}


#pragma mark - event response

#pragma mark - private methods

#pragma mark - accessor methods

#pragma mark - api methods



@end
