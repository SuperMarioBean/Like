//
//  LIKETrendViewModel.m
//  like
//
//  Created by David Fu on 7/13/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKETrendViewModel.h"

NSString *const LIKEFeedItemElementKindCellContent = @"com.trinity.like.trend.cell.kind.content";
NSString *const LIKEFeedItemElementKindCellAction = @"com.trinity.like.trend.cell.kind.action";

NSString *const LIKEFeedItemHeaderIdentifier = @"com.trinity.like.trend.header";

NSString *const LIKEFeedItemContentCellIdentifier = @"com.trinity.like.trend.cell.identifier.content";
NSString *const LIKEFeedItemActionCellIdentifier = @"com.trinity.like.trend.cell.identifier.action";

NSString *const LIKEFeedItemFooterIdentifier = @"com.trinity.like.trend.footer";

@interface LIKETrendViewModel ()

@property (readwrite, nonatomic, strong) NSMutableArray *feedsArray;

@end

@implementation LIKETrendViewModel

#pragma mark - life cycle

- (void)dealloc {
    self.feedsArray = nil;
}

- (instancetype)init {
    return [self initWithFeedsArray:[LIKEAppContext sharedInstance].testTrendsArray];
}

- (instancetype)initWithFeedsArray:(NSMutableArray *)feedsArray {
    self = [super init];
    if (self) {
        _feedsArray = feedsArray;
    }
    return self;
}

#pragma mark - delegate methods

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self numberOfItemsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *kind = [self cellKindForIndexPath:indexPath];
    UICollectionViewCell *cell;
    if ([kind isEqualToString:LIKEFeedItemElementKindCellContent]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:LIKEFeedItemContentCellIdentifier forIndexPath:indexPath];
    }
    else if ([kind isEqualToString:LIKEFeedItemElementKindCellAction]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:LIKEFeedItemActionCellIdentifier forIndexPath:indexPath];
    }
    
    [self configureCell:cell kind:kind indexPath:indexPath];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
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
    [self configureReusableView:reusableView kind:kind indexPath:indexPath];
    return reusableView;
}

#pragma mark - event response

#pragma mark - private methods

#pragma mark - accessor methods

#pragma mark - api methods

/** 每一个数据集对应一个section */
- (NSInteger)numberOfSections {
    return self.feedsArray.count;
}

/** content, action这两个cell */
- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    return 1 + 1;
}

- (id)objectForIndexPath:(NSIndexPath *)indexPath {
    return self.feedsArray[indexPath.section];
}

- (NSString *)cellKindForIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == 0) {
        return LIKEFeedItemElementKindCellContent;
    }
    else if (indexPath.item == 1) {
        return LIKEFeedItemElementKindCellAction;
    }
    return nil;
}

- (void)configureCell:(UICollectionViewCell *)collectionViewCell kind:(NSString *)kind indexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:LIKEFeedItemElementKindCellContent]) {
        LIKEFeedItemContentCell *cell = (LIKEFeedItemContentCell *)collectionViewCell;
        NSDictionary *feed = [self objectForIndexPath:indexPath];
        [cell.photoImageView sd_setImageWithURL:feed[LIKETrendContentImageURL]];
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
}

- (void)configureReusableView:(UICollectionReusableView *)collectionReusableView kind:(NSString *)kind  indexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        LIKEFeedItemHeader *header = (LIKEFeedItemHeader *)collectionReusableView;
        NSDictionary *feed = [self objectForIndexPath:indexPath];
        [header.avatarImageView sd_setImageWithURL:feed[LIKETrendUserAvatarURL]];
        header.nicknameLabel.text = feed[LIKETrendUserNickname];
        header.genderAndAgeLabel.text = [NSString stringWithFormat:@"%@  %@", [feed[LIKETrendUserGender] boolValue]? LIKEUserGenderMale: LIKEUserGenderFemale, [feed[LIKETrendUserAge] stringValue]];
        header.genderAndAgeLabel.backgroundColor = [feed[LIKETrendUserGender] boolValue]? [UIColor blueColor]: [UIColor magentaColor];
        header.timelineLabel.text = [feed[LIKETrendTimeline] timeAgoSimple];
        header.locationLabel.text = feed[LIKETrendUserLocation];
    }
    else if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
    }
}

@end
