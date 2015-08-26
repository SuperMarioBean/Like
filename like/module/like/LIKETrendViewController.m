//
//  LIKEChosenViewController.m
//  like
//
//  Created by David Fu on 6/23/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKETrendViewController.h"

#import "LIKETrendLayout.h"
#import "LIKETrendViewModel.h"

#define LIKECellAcitonHeight 44

@interface LIKETrendViewController () <UICollectionViewDelegateFlowLayout>

@property (readwrite, nonatomic, strong) LIKETrendViewModel *viewModel;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet LIKETrendLayout *trendLayout;

@property (readwrite, nonatomic, strong) SSPullToRefreshView *topRefreshView;

@end

@implementation LIKETrendViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"LIKEFeedItemUploadCell" bundle:nil]
          forCellWithReuseIdentifier:LIKEFeedItemUploadCellIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:@"LIKEFeedItemContentCell" bundle:nil]
          forCellWithReuseIdentifier:LIKEFeedItemContentCellIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:@"LIKEFeedItemActionCell" bundle:nil]
          forCellWithReuseIdentifier:LIKEFeedItemActionCellIdentifier];

    [self.collectionView registerNib:[UINib nibWithNibName:@"LIKEFeedItemHeader" bundle:nil]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:LIKEFeedItemHeaderIdentifier];
    
    self.viewModel = [[LIKETrendViewModel alloc] init];
    self.collectionView.dataSource = self.viewModel;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccessHandler:) name:LIKELoginSuccessNotification object:nil];
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([LIKEAppContext sharedInstance].testUploadTrendsArray.count) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]
                                    atScrollPosition:UICollectionViewScrollPositionTop
                                            animated:NO];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    }
}

#pragma mark - delegate methods

#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *kind = [self.viewModel cellKindForIndexPath:indexPath];
    CGSize size;
    if ([kind isEqualToString:LIKEFeedItemElementKindCellContent]) {
        
        size = [collectionView ar_sizeForCellWithIdentifier:LIKEFeedItemContentCellIdentifier
                                                  indexPath:indexPath
                                                 fixedWidth:CGRectGetWidth(self.collectionView.frame)
                                              configuration:^(id cell) {
                                                  [self.viewModel configureCollectionView:collectionView
                                                                                     cell:cell
                                                                                     kind:LIKEFeedItemElementKindCellContent
                                                                                indexPath:indexPath];
                                              }];
    }
    else if ([kind isEqualToString:LIKEFeedItemElementKindCellAction]) {
        size = CGSizeMake(CGRectGetWidth(self.collectionView.frame), LIKECellAcitonHeight);
    }
    else if ([kind isEqualToString:LIKEFeedItemElementKindCellUpload]) {
        size = CGSizeMake(CGRectGetWidth(self.collectionView.frame), LIKECellAcitonHeight);
    }
    
    return size;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section != 0) {
        return CGSizeMake(CGRectGetWidth(self.collectionView.frame), 54);
    }
    return CGSizeMake(0, 0);
}

#pragma mark SSPullToRefreshViewDelegate

- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView *)view {
    [view finishLoading];
}

#pragma mark - event response

- (void)loginSuccessHandler:(NSNotification *)notification {
    [self topRefresh];
}

- (void)bottomRefresh {
    [self.viewModel loadDataWithRefreshFlag:NO
                                 completion:^(NSError *error,
                                              NSIndexSet *appendIndexSet) {
        if (!error) {
            [self.collectionView insertSections:appendIndexSet];
        }
        else {
            // TODO: show did not fetch anything
        }
    }];
}

- (void)topRefresh {
    [self.viewModel loadDataWithRefreshFlag:YES
                                 completion:^(NSError *error,
                                              NSIndexSet *appendIndexSet) {
                                     [self.topRefreshView finishLoading];
        if (!error) {
//            /[self.collectionView insertSections:appendIndexSet];
            [self.collectionView reloadData];
        }
        else {
            // TODO: show did not fetch anything
        }
    }];
}


#pragma mark - private methods

#pragma mark - accessor methods

- (SSPullToRefreshView *)topRefreshView {
    if (!_topRefreshView) {
        _topRefreshView = [[SSPullToRefreshView alloc] initWithScrollView:self.collectionView delegate:self];
    }
    return _topRefreshView;
}

#pragma mark - api methods



@end
