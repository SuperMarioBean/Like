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

#define LIKECellAcitonHeight 46

@interface LIKETrendViewController () <UICollectionViewDelegateFlowLayout>

@property (readwrite, nonatomic, strong) LIKETrendViewModel *viewModel;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet LIKETrendLayout *trendLayout;

@end

@implementation LIKETrendViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"LIKEFeedItemContentCell" bundle:nil]
          forCellWithReuseIdentifier:LIKEFeedItemContentCellIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:@"LIKEFeedItemActionCell" bundle:nil]
          forCellWithReuseIdentifier:LIKEFeedItemActionCellIdentifier];

    [self.collectionView registerNib:[UINib nibWithNibName:@"LIKEFeedItemHeader" bundle:nil]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:LIKEFeedItemHeaderIdentifier];
    
    self.trendLayout.headerReferenceSize = CGSizeMake(CGRectGetWidth(self.collectionView.frame), 66);
    
    self.viewModel = [[LIKETrendViewModel alloc] init];
    self.collectionView.dataSource = self.viewModel;
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *kind = [self.viewModel cellKindForIndexPath:indexPath];
    CGSize size;
    if ([kind isEqualToString:LIKEFeedItemElementKindCellContent]) {
        
        size = [collectionView ar_sizeForCellWithIdentifier:LIKEFeedItemContentCellIdentifier
                                                  indexPath:indexPath
                                                 fixedWidth:CGRectGetWidth(self.collectionView.frame)
                                              configuration:^(id cell) {
                                                  [self.viewModel configureCell:cell
                                                                           kind:LIKEFeedItemElementKindCellContent
                                                                      indexPath:indexPath];
                                              }];
    }
    else if ([kind isEqualToString:LIKEFeedItemElementKindCellAction]) {
        size = CGSizeMake(CGRectGetWidth(self.collectionView.frame), LIKECellAcitonHeight);
    }
    
    return size;
}

#pragma mark - event response

#pragma mark - private methods

#pragma mark - accessor methods

#pragma mark - api methods



@end
