//
//  LIKEMineDetailViewModel.m
//  like
//
//  Created by David Fu on 7/27/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKEMineDetailViewModel.h"

#import "LIKEMineDetailHeaderView.h"
#import "LIKEMineStatisticsHeaderView.h"

#import "LIKEMineTrendItem.h"
#import "LIKEMinePhotoItem.h"

NSString *const LIKEMineItemElementKindCellTrend = @"com.trinity.like.mine.cell.kind.trend";
NSString *const LIKEMineItemElementKindCellPhoto = @"com.trinity.like.mine.cell.kind.photo";
NSString *const LIKEMineItemElementKindCellWant = @"com.trinity.like.mine.cell.kind.want";
NSString *const LIKEMineItemElementKindCellDinner = @"com.trinity.like.mine.cell.kind.dinner";
NSString *const LIKEMineItemElementKindCellQuestion = @"com.trinity.like.mine.cell.kind.question";

NSString *const LIKEMineItemElementKindHeaderDetail = @"com.trinity.like.mine.header.kind.detail";
NSString *const LIKEMineItemElementKindHeaderStatistics = @"com.trinity.like.mine.header.kind.Statistics";

NSString *const LIKEMineItemTrendCellIdentifier = @"com.trinity.like.mine.cell.identifier.trend";
NSString *const LIKEMineItemPhotoCellIdentifier = @"com.trinity.like.mine.cell.identifier.photo";
NSString *const LIKEMineItemWantCellIdentifier = @"com.trinity.like.mine.cell.identifier.want";
NSString *const LIKEMineItemDinnerCellIdentifier = @"com.trinity.like.mine.cell.identifier.dinner";
NSString *const LIKEMineItemQuestionCellIdentifier = @"com.trinity.like.mine.cell.identifier.question";

NSString *const LIKEMineItemDetailHeaderIdentifier = @"com.trinity.like.mine.header.detail";
NSString *const LIKEMineItemStatisticsHeaderIdentifier = @"com.trinity.like.mine.header.Statistics";

@interface LIKEMineDetailViewModel ()

@property (readwrite, nonatomic, strong) LIKEUser *user;

@end

@implementation LIKEMineDetailViewModel

#pragma mark - life cycle

-(void)dealloc {
    self.user = nil;
}

- (instancetype)init {
    return [self initWithUser:[LIKEUserContext sharedInstance].user];
}

- (instancetype)initWithUser:(LIKEUser *)user {
    self = [super init];
    if (self) {
        _user = user;
        _itemType = LIKEMineItemTypePhotos;
    }
    return self;
}

#pragma mark - delegate methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return [self numberOfItemsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *kind = [self cellKindForIndexPath:indexPath];
    UICollectionViewCell *cell;
    if ([kind isEqualToString:LIKEMineItemElementKindCellTrend]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:LIKEMineItemTrendCellIdentifier
                                                         forIndexPath:indexPath];
    }
    else if ([kind isEqualToString:LIKEMineItemElementKindCellPhoto]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:LIKEMineItemPhotoCellIdentifier
                                                         forIndexPath:indexPath];
    }
    else if ([kind isEqualToString:LIKEMineItemElementKindCellWant]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:LIKEMineItemWantCellIdentifier
                                                         forIndexPath:indexPath];
    }
    else if ([kind isEqualToString:LIKEMineItemElementKindCellDinner]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:LIKEMineItemDinnerCellIdentifier
                                                         forIndexPath:indexPath];
    }
    else if ([kind isEqualToString:LIKEMineItemElementKindCellQuestion]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:LIKEMineItemQuestionCellIdentifier
                                                         forIndexPath:indexPath];
    }
    
    [self configureCollectionView:collectionView
                             cell:cell
                             kind:kind
                        indexPath:indexPath];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView;
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {

    }
    else if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        NSString *headerKind = [self headerKindForIndexPath:indexPath];
        if ([headerKind isEqualToString:LIKEMineItemElementKindHeaderDetail]) {
            reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                              withReuseIdentifier:LIKEMineItemDetailHeaderIdentifier
                                                                     forIndexPath:indexPath];

        }
        else if ([headerKind isEqualToString:LIKEMineItemElementKindHeaderStatistics]) {
            reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                              withReuseIdentifier:LIKEMineItemStatisticsHeaderIdentifier
                                                                     forIndexPath:indexPath];
        }
    }
    [self configureCollectionView:collectionView
                     reusableView:reusableView
                             kind:kind
                        indexPath:indexPath];
    
    return reusableView;
}


#pragma mark - event response

#pragma mark - private methods

- (NSString *)headerKindForIndexPath:(NSIndexPath *)indexPath {
    return [self headerKindForSection:indexPath.section];
}

#pragma mark - accessor methods

#pragma mark - api methods

/** 每一个数据集对应一个section 外加一个uoload的section */
- (NSInteger)numberOfSections {
    return 2;
}

/** content, action这两个cell */
- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    else if (section == 1) {
        switch (self.itemType) {
            case LIKEMineItemTypePhotos:
                return self.user.testPhotosArray.count;
                break;
            case LIKEMineItemTypeWants:
                return self.user.testWantsArray.count;
                break;
            case LIKEMineItemTypeDinners:
                return self.user.testDinnersArray.count;
                break;
            case LIKEMineItemTypeQuestions:
                return self.user.testQuestionsArray.count;
                break;
            default:
                break;
        }
    }
    return 0;
}

- (id)objectForIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [self.user.testTrendsArray lastObject];
    }
    else if (indexPath.section == 1){
        switch (self.itemType) {
            case LIKEMineItemTypePhotos:
                return self.user.testPhotosArray[indexPath.item];
                break;
            case LIKEMineItemTypeWants:
                return self.user.testWantsArray[indexPath.item];
                break;
            case LIKEMineItemTypeDinners:
                return self.user.testDinnersArray[indexPath.item];
                break;
            case LIKEMineItemTypeQuestions:
                return self.user.testQuestionsArray[indexPath.item];
                break;
            default:
                break;
        }
    }
    return nil;
}

- (NSString *)cellKindForIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return LIKEMineItemElementKindCellTrend;
    }
    else if (indexPath.section == 1) {
        switch (self.itemType) {
            case LIKEMineItemTypePhotos:
                return LIKEMineItemElementKindCellPhoto;
                break;
            case LIKEMineItemTypeWants:
                return LIKEMineItemElementKindCellWant;
                break;
            case LIKEMineItemTypeDinners:
                return LIKEMineItemElementKindCellDinner;
                break;
            case LIKEMineItemTypeQuestions:
                return LIKEMineItemElementKindCellQuestion;
                break;
            default:
                break;
        }
    }
    return nil;
}

- (NSString *)headerKindForSection:(NSInteger)section {
    if (section == 0) {
        return LIKEMineItemElementKindHeaderDetail;
    }
    else if (section == 1) {
        return LIKEMineItemElementKindHeaderStatistics;
    }
    return nil;
}

- (void)configureCollectionView:(UICollectionView *)collectionView
                           cell:(UICollectionViewCell *)collectionViewCell
                           kind:(NSString *)kind
                      indexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:LIKEMineItemElementKindCellTrend]) {
        LIKEMineTrendItem *cell = (LIKEMineTrendItem *)collectionViewCell;
        NSDictionary *trend = [self objectForIndexPath:indexPath];
        if (!trend) {
            cell.trendsCountLabel.text = @"0";
            cell.latestTrendSortLabel.text = @"";
            cell.latestDescriptionLabel.text = @"";
            cell.latestTimeLabel.text = @"";
        }
        else {
            cell.trendsCountLabel.text = [NSString stringWithFormat:@"%d", self.user.testTrendsArray.count];
            [cell.latestTrendImageView sd_setImageWithURL:trend[LIKETrendContentImageURL]];
            cell.latestTrendSortLabel.text = @"上传了照片";
            cell.latestDescriptionLabel.text = trend[LIKETrendContentText];
            cell.latestTimeLabel.text = [trend[LIKETrendTimeline] timeAgoSimple];
        }
    }
    else if ([kind isEqualToString:LIKEMineItemElementKindCellPhoto]) {
        LIKEMinePhotoItem *cell = (LIKEMinePhotoItem *)collectionViewCell;
        NSDictionary *photo = [self objectForIndexPath:indexPath];
        [cell.photoImageView sd_setImageWithURL:photo[LIKEUserPhotoURL]];
    }
    else if ([kind isEqualToString:LIKEMineItemElementKindCellWant]) {
    
    }
    else if ([kind isEqualToString:LIKEMineItemElementKindCellDinner]) {
       
    }
    else if ([kind isEqualToString:LIKEMineItemElementKindCellQuestion]) {
    }
}

- (void)configureCollectionView:(UICollectionView *)collectionView
                   reusableView:(UICollectionReusableView *)collectionReusableView
                           kind:(NSString *)kind
                      indexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        NSString *headerKind = [self headerKindForIndexPath:indexPath];
        if ([headerKind isEqualToString:LIKEMineItemElementKindHeaderDetail]) {
            LIKEMineDetailHeaderView *header = (LIKEMineDetailHeaderView *)collectionReusableView;
            [header.avatarImageView sd_setImageWithURL:self.user.avatorURL];
        }
        else if ([headerKind isEqualToString:LIKEMineItemElementKindHeaderStatistics]) {
            LIKEMineStatisticsHeaderView *header = (LIKEMineStatisticsHeaderView *)collectionReusableView;
            [header.photosButton setTitle:[NSString stringWithFormat:@"%d", self.user.testPhotosArray.count]
                                 forState:UIControlStateNormal];
            [header.wantsButton setTitle:[NSString stringWithFormat:@"%d", self.user.testWantsArray.count]
                                forState:UIControlStateNormal];
            [header.dinnersButton setTitle:[NSString stringWithFormat:@"%d", self.user.testDinnersArray.count]
                                  forState:UIControlStateNormal];
            [header.questionsButton setTitle:[NSString stringWithFormat:@"%d", self.user.testQuestionsArray.count]
                                    forState:UIControlStateNormal];
        }
    }
    else if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
    }
}

@end
