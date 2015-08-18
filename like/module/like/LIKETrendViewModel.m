//
//  LIKETrendViewModel.m
//  like
//
//  Created by David Fu on 7/13/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKETrendViewModel.h"

//NSString *const LIKEFeedItemSectionKindSectionUpload = @"com.trinity.like.trend.section.kind.upload";
//NSString *const LIKEFeedItemSectionKindSectionFeed = @"com.trinity.like.trend.section.kind.feed";

NSString *const LIKEFeedItemElementKindCellUpload = @"com.trinity.like.trend.cell.kind.upload";
NSString *const LIKEFeedItemElementKindCellContent = @"com.trinity.like.trend.cell.kind.content";
NSString *const LIKEFeedItemElementKindCellAction = @"com.trinity.like.trend.cell.kind.action";

NSString *const LIKEFeedItemHeaderIdentifier = @"com.trinity.like.trend.header";

NSString *const LIKEFeedItemUploadCellIdentifier = @"com.trinity.like.trend.cell.identifier.upload";
NSString *const LIKEFeedItemContentCellIdentifier = @"com.trinity.like.trend.cell.identifier.content";
NSString *const LIKEFeedItemActionCellIdentifier = @"com.trinity.like.trend.cell.identifier.action";

NSString *const LIKEFeedItemFooterIdentifier = @"com.trinity.like.trend.footer";

@interface LIKETrendViewModel ()

@property (readwrite, nonatomic, strong) NSMutableArray *feedsArray;

@property (readwrite, nonatomic, strong) NSMutableArray *uploadsArray;

@end

@implementation LIKETrendViewModel

#pragma mark - life cycle

- (void)dealloc {
    self.feedsArray = nil;
    self.uploadsArray = nil;
}

- (instancetype)init {
    return [self initWithFeedsArray:[LIKEPostContext sharedInstance].timelineList
                       uploadsArray:[LIKEPostContext sharedInstance].uploadList];
}

- (instancetype)initWithFeedsArray:(NSMutableArray *)feedsArray
                      uploadsArray:(NSMutableArray *)uploadsArray{
    self = [super init];
    if (self) {
        _feedsArray = feedsArray;
        _uploadsArray = uploadsArray;
    }
    return self;
}

#pragma mark - delegate methods

#pragma mark - UICollectionViewDataSource

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
    if ([kind isEqualToString:LIKEFeedItemElementKindCellContent]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:LIKEFeedItemContentCellIdentifier
                                                         forIndexPath:indexPath];
    }
    else if ([kind isEqualToString:LIKEFeedItemElementKindCellAction]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:LIKEFeedItemActionCellIdentifier
                                                         forIndexPath:indexPath];
    }
    else if ([kind isEqualToString:LIKEFeedItemElementKindCellUpload]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:LIKEFeedItemUploadCellIdentifier
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
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                          withReuseIdentifier:LIKEFeedItemFooterIdentifier
                                                                 forIndexPath:indexPath];
    }
    else if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                          withReuseIdentifier:LIKEFeedItemHeaderIdentifier
                                                                 forIndexPath:indexPath];
    }
    [self configureCollectionView:collectionView
                     reusableView:reusableView
                             kind:kind
                        indexPath:indexPath];

    return reusableView;
}

#pragma mark - event response

#pragma mark - private methods

#pragma mark - accessor methods

#pragma mark - api methods

/** 每一个数据集对应一个section 外加一个uoload的section */
- (NSInteger)numberOfSections {
    return 1 + self.feedsArray.count;
}

/** content, action这两个cell */
- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return self.uploadsArray.count;
    }

    return 1 + 1;
}

- (id)objectForIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return self.uploadsArray[indexPath.item];
    }
    else {
        return self.feedsArray[indexPath.section - 1];
    }
    return nil;
}

- (NSString *)cellKindForIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return LIKEFeedItemElementKindCellUpload;
    }
    else {
        if (indexPath.item == 0) {
            return LIKEFeedItemElementKindCellContent;
        }
        else if (indexPath.item == 1) {
            return LIKEFeedItemElementKindCellAction;
        }
    }
    return nil;
}

- (void)configureCollectionView:(UICollectionView *)collectionView
                           cell:(UICollectionViewCell *)collectionViewCell
                           kind:(NSString *)kind
                      indexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:LIKEFeedItemElementKindCellContent]) {
        LIKEFeedItemContentCell *cell = (LIKEFeedItemContentCell *)collectionViewCell;
        NSDictionary *feed = [self objectForIndexPath:indexPath];
        NSURL *url = [NSURL URLWithString:feed[LIKETrendContentImageURL]];
        if ([url isEqual:[NSNull null]]) {
            cell.photoImageView.image = feed[LIKETrendContentImage];
        }
        else {
            [cell.photoImageView sd_setImageWithURL:url];
        }
        cell.contentLabel.text = feed[LIKETrendContentText];
        
        [cell beginTagsUpdate];
        for (NSDictionary *tagMeta in feed[LIkeTrendContentTagList]) {
            CGPoint point = CGPointFromString(tagMeta[LIKETagPosition]);
            [cell updateTagWithPoint:point
                               title:tagMeta[LIKETagTitle]
                                type:[tagMeta[LIKETagType] integerValue]
                           direction:[tagMeta[LIKETagDirection] integerValue]];
        }
        [cell endTagsUpdate];
    }
    else if ([kind isEqualToString:LIKEFeedItemElementKindCellAction]){
        
    }
    else if ([kind isEqualToString:LIKEFeedItemElementKindCellUpload]) {
        LIKEFeedItemUploadCell *cell = (LIKEFeedItemUploadCell *)collectionViewCell;
        NSDictionary *upload = [self objectForIndexPath:indexPath];
        cell.thumbnailImageView.image = upload[LIKEUploadThumbnailImage];
        cell.status = LIKEFeedItemUploadStatusSending;
        [cell.uploadProgressView setProgress:0.0f animated:NO];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [cell.uploadProgressView setProgress:1.0f animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                cell.status = LIKEFeedItemUploadStatusSent;
                [collectionView performBatchUpdates:^{
                    [[LIKEAppContext sharedInstance].testUploadTrendsArray removeObject:upload];
                    [collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
                } completion:^(BOOL finished) {
                    [[LIKEAppContext sharedInstance].testTrendsArray insertObject:upload atIndex:0];
                    [collectionView insertSections:[NSIndexSet indexSetWithIndex:1]];
                }];
            });
        });
    }
}

- (void)configureCollectionView:(UICollectionView *)collectionView
                   reusableView:(UICollectionReusableView *)collectionReusableView
                           kind:(NSString *)kind
                      indexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        LIKEFeedItemHeader *header = (LIKEFeedItemHeader *)collectionReusableView;
        NSDictionary *feed = [self objectForIndexPath:indexPath];
        [header.avatarImageView sd_setImageWithURL:[NSURL URLWithString:feed[LIKETrendUserAvatarURL]]];
        header.nicknameLabel.text = feed[LIKETrendUserNickname];
        header.genderAndAgeLabel.text = [NSString stringWithFormat:@"%@  %@", [feed[LIKETrendUserGender] boolValue]? LIKEUserGenderMale: LIKEUserGenderFemale, feed[LIKETrendUserAge]];
        header.genderAndAgeLabel.backgroundColor = [feed[LIKETrendUserGender] boolValue]? [UIColor blueColor]: [UIColor magentaColor];
        NSDate *date = [NSDate dateWithTimeIntervalStringInMilliSecondSince1970:feed[LIKETrendTimeline]];
        header.timelineLabel.text = [date timeAgoSimple];
        header.locationLabel.text = feed[LIKETrendUserLocation];
    }
    else if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
    }
}

- (void)loadDataWithRefreshFlag:(BOOL)refreshFlag
                     completion:(void (^)(NSError *, NSIndexSet *))completion {
    NSUInteger page = refreshFlag? 1: [LIKEPostContext sharedInstance].currentTimelinePage + 1;
    [[LIKEPostContext sharedInstance] timelineWithPage:page
                                            completion:^(NSError *error,
                                                         NSArray *appendPostsArray) {
                                                if (!error) {
                                                    NSUInteger location = refreshFlag? 0: [LIKEPostContext sharedInstance].timelineList.count;
                                                    NSUInteger length = appendPostsArray.count;
                                                    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(location, length)];
                                                    completion(nil, indexSet);
                                                }
                                                else {
                                                    completion(error, nil);
                                                }
                                            }];
}

@end
