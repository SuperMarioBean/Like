//
//  LIKETrendViewModel.h
//  like
//
//  Created by David Fu on 7/13/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LIKEFeedItemHeader.h"
#import "LIKEFeedItemContentCell.h"
#import "LIKEFeedItemActionCell.h"
#import "LIKEFeedItemUploadCell.h"
#import "TagView.h"

//extern NSString *const LIKEFeedItemSectionKindSectionUpload;
//extern NSString *const LIKEFeedItemSectionKindSectionFeed;

extern NSString *const LIKEFeedItemElementKindCellContent;
extern NSString *const LIKEFeedItemElementKindCellAction;
extern NSString *const LIKEFeedItemElementKindCellUpload;

extern NSString *const LIKEFeedItemHeaderIdentifier;

extern NSString *const LIKEFeedItemUploadCellIdentifier;
extern NSString *const LIKEFeedItemContentCellIdentifier;
extern NSString *const LIKEFeedItemActionCellIdentifier;

extern NSString *const LIKEFeedItemFooterIdentifier;

@interface LIKETrendViewModel : NSObject <UICollectionViewDataSource>

- (instancetype)initWithFeedsArray:(NSMutableArray *)feedsArray
                      uploadsArray:(NSMutableArray *)uploadsArray;

- (NSInteger)numberOfSections;

- (NSInteger)numberOfItemsInSection:(NSInteger)section;

- (id)objectForIndexPath:(NSIndexPath *)indexPath;

- (NSString *)cellKindForIndexPath:(NSIndexPath *)indexPath;
//- (NSString *)sectionKindForIndexPath:(NSIndexPath *)indexPath;

- (void)configureCollectionView:(UICollectionView *)collectionView
                           cell:(UICollectionViewCell *)collectionViewCell
                           kind:(NSString *)kind
                      indexPath:(NSIndexPath *)indexPath;

- (void)configureCollectionView:(UICollectionView *)collectionView
                   reusableView:(UICollectionReusableView *)collectionReusableView
                           kind:(NSString *)kind
                      indexPath:(NSIndexPath *)indexPath;

- (void)loadDataWithRefreshFlag:(BOOL)refreshFlag
                     completion:(void (^)(NSError *error, NSIndexSet *appendIndexSet))completion;

@end
