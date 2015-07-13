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
#import "TagView.h"

extern NSString *const LIKEFeedItemElementKindCellContent;
extern NSString *const LIKEFeedItemElementKindCellAction;

extern NSString *const LIKEFeedItemHeaderIdentifier;

extern NSString *const LIKEFeedItemContentCellIdentifier;
extern NSString *const LIKEFeedItemActionCellIdentifier;

extern NSString *const LIKEFeedItemFooterIdentifier;

@interface LIKETrendViewModel : NSObject <UICollectionViewDataSource>

- (instancetype)initWithFeedsArray:(NSMutableArray *)feedsArray;

- (NSInteger)numberOfSections;

- (NSInteger)numberOfItemsInSection:(NSInteger)section;

- (id)objectForIndexPath:(NSIndexPath *)indexPath;

- (NSString *)cellKindForIndexPath:(NSIndexPath *)indexPath;

- (void)configureCell:(UICollectionViewCell *)collectionViewCell kind:(NSString *)kind indexPath:(NSIndexPath *)indexPath;

- (void)configureReusableView:(UICollectionReusableView *)collectionReusableView kind:(NSString *)kind indexPath:(NSIndexPath *)indexPath;

@end
