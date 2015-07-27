//
//  LIKEMineDetailViewModel.h
//  like
//
//  Created by David Fu on 7/27/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const LIKEMineItemElementKindCellTrend;
extern NSString *const LIKEMineItemElementKindCellPhoto;
extern NSString *const LIKEMineItemElementKindCellWant;
extern NSString *const LIKEMineItemElementKindCellDinner;
extern NSString *const LIKEMineItemElementKindCellQuestion;

extern NSString *const LIKEMineItemElementKindHeaderDetail;
extern NSString *const LIKEMineItemElementKindHeaderStatistics;

extern NSString *const LIKEMineItemTrendCellIdentifier;
extern NSString *const LIKEMineItemPhotoCellIdentifier;
extern NSString *const LIKEMineItemWantCellIdentifier;
extern NSString *const LIKEMineItemDinnerCellIdentifier;
extern NSString *const LIKEMineItemQuestionCellIdentifier;

extern NSString *const LIKEMineItemDetailHeaderIdentifier;
extern NSString *const LIKEMineItemStatisticsHeaderIdentifier;

typedef NS_ENUM(NSUInteger, LIKEMineItemType) {
    LIKEMineItemTypePhotos,
    LIKEMineItemTypeWants,
    LIKEMineItemTypeDinners,
    LIKEMineItemTypeQuestions,
};

@interface LIKEMineDetailViewModel : NSObject <UICollectionViewDataSource>

@property (readwrite, nonatomic, assign) LIKEMineItemType itemType;

- (NSInteger)numberOfSections;

- (NSInteger)numberOfItemsInSection:(NSInteger)section;

- (id)objectForIndexPath:(NSIndexPath *)indexPath;

- (NSString *)cellKindForIndexPath:(NSIndexPath *)indexPath;

- (NSString *)headerKindForSection:(NSInteger)section;

- (void)configureCollectionView:(UICollectionView *)collectionView
                           cell:(UICollectionViewCell *)collectionViewCell
                           kind:(NSString *)kind
                      indexPath:(NSIndexPath *)indexPath;

- (void)configureCollectionView:(UICollectionView *)collectionView
                   reusableView:(UICollectionReusableView *)collectionReusableView
                           kind:(NSString *)kind
                      indexPath:(NSIndexPath *)indexPath;

@end
