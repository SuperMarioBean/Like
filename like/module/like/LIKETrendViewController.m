//
//  LIKEChosenViewController.m
//  like
//
//  Created by David Fu on 6/23/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKETrendViewController.h"

#import "LIKETrendLayout.h"
#import "LIKETrendCollectionViewCell.h"
#import "LIKETrendCollectionViewHeader.h"

static NSString *const LIKETrendUserAvatarURL = @"userAvatarURL";
static NSString *const LIKETrendUserNickname = @"userNickname";
static NSString *const LIKETrendUserGender = @"userGender";
static NSString *const LIKETrendUserAge = @"userAge";
static NSString *const LIKETrendUserLocation = @"userLocation";
static NSString *const LIKETrendTimeline = @"userTimeline";
static NSString *const LIKETrendContentImageURL = @"contentImageURL";
static NSString *const LIKETrendContentText = @"contentText";

static NSString *const LIKECollectionViewCellIdentifier = @"com.trinity.like.trend.cell";
static NSString *const LIKECollectionViewHeaderIdentifier = @"com.trinity.like.trend.header";
static NSString *const LIKECollectionViewFooterIdentifier = @"com.trinity.like.trend.footer";

@interface LIKETrendViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (readwrite, nonatomic, strong) NSMutableArray *trends;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet LIKETrendLayout *trendLayout;

@end

@implementation LIKETrendViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"LIKETrendCollectionViewCell" bundle:nil]
          forCellWithReuseIdentifier:LIKECollectionViewCellIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:@"LIKETrendCollectionViewHeader" bundle:nil]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:LIKECollectionViewHeaderIdentifier];
    self.trendLayout.headerReferenceSize = CGSizeMake(CGRectGetWidth(self.collectionView.frame), 66);
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

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.trends.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:LIKECollectionViewCellIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell object:self.trends[indexPath.section] indexPath:indexPath];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView;
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                          withReuseIdentifier:LIKECollectionViewFooterIdentifier
                                                                 forIndexPath:indexPath];
    }
    else if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                          withReuseIdentifier:LIKECollectionViewHeaderIdentifier
                                                                 forIndexPath:indexPath];

    }
    [self configureReusableView:reusableView kind:kind object:self.trends[indexPath.section] indexPath:indexPath];
    return reusableView;
}

#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = [collectionView ar_sizeForCellWithIdentifier:LIKECollectionViewCellIdentifier
                                                     indexPath:indexPath
                                                    fixedWidth:CGRectGetWidth(self.collectionView.frame)
                                                 configuration:^(id cell) {
                                                     [self configureCell:cell
                                                                  object:self.trends[indexPath.section]
                                                               indexPath:indexPath];
                                                 }];
    
    return size;
}

#pragma mark - event response

- (void)configureCell:(UICollectionViewCell *)collectionViewCell object:(id)object indexPath:(NSIndexPath *)indexPath{
    LIKETrendCollectionViewCell *cell = (LIKETrendCollectionViewCell *)collectionViewCell;
    NSDictionary *trend = (NSDictionary *)object;
    [cell.imageView sd_setImageWithURL:trend[LIKETrendContentImageURL]];
    cell.trendContentLabel.text = trend[LIKETrendContentText];
}

- (void)configureReusableView:(UICollectionReusableView *)collectionReusableView kind:(NSString *)kind object:(id)object indexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        LIKETrendCollectionViewHeader *header = (LIKETrendCollectionViewHeader *)collectionReusableView;
        NSDictionary *trend = (NSDictionary *)object;
        [header.avatarImageView sd_setImageWithURL:trend[LIKETrendUserAvatarURL]];
        header.nicknameLabel.text = trend[LIKETrendUserNickname];
        header.genderAndAgeLabel.text = [NSString stringWithFormat:@"%@  %@", [trend[LIKETrendUserGender] boolValue]? LIKEUserGenderMale: LIKEUserGenderFemale, [trend[LIKETrendUserAge] stringValue]];
        header.genderAndAgeLabel.backgroundColor = [trend[LIKETrendUserGender] boolValue]? [UIColor blueColor]: [UIColor magentaColor];
        header.timelineLabel.text = [trend[LIKETrendTimeline] timeAgoSimple];
        header.locationLabel.text = trend[LIKETrendUserLocation];
    }
    else if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
    }
}

#pragma mark - private methods

#pragma mark - accessor methods

- (NSMutableArray *)trends {
    if (!_trends) {
        _trends = [NSMutableArray array];
        NSDictionary *text1 = @{LIKETrendUserAvatarURL: [NSURL URLWithString:@"http://7xjvx7.com1.z0.glb.clouddn.com/m9.png"],
                                LIKETrendUserNickname: @"林星元",
                                LIKETrendUserGender: @YES,
                                LIKETrendUserAge: @(21),
                                LIKETrendTimeline: [NSDate date],
                                LIKETrendUserLocation: @"上海",
                                LIKETrendContentImageURL: [NSURL URLWithString:@"http://7xjljl.com1.z0.glb.clouddn.com/ef8e65a2-198d-11e5-bb92-00163e004f70"],
                                LIKETrendContentText: @"今天真是一个好天气,兄弟们,一起出来耍~"
                                };
        
        NSDictionary *text2 = @{LIKETrendUserAvatarURL: [NSURL URLWithString:@"http://7xjvx7.com1.z0.glb.clouddn.com/m2.png"],
                                LIKETrendUserNickname: @"张力泳",
                                LIKETrendUserGender: @YES,
                                LIKETrendUserAge: @(23),
                                LIKETrendTimeline: [NSDate date],
                                LIKETrendUserLocation: @"上海",
                                LIKETrendContentImageURL: [NSURL URLWithString:@"http://7xjljl.com1.z0.glb.clouddn.com/eeefa9c6-198d-11e5-bb92-00163e004f70"],
                                LIKETrendContentText: @"今天遇到一个不错的姑娘,可惜错过了,希望下次不会有下次,大家也都要抓住机会,不要放过"
                                };
        
        NSDictionary *text3 = @{LIKETrendUserAvatarURL: [NSURL URLWithString:@"http://7xjvx7.com1.z0.glb.clouddn.com/f6.png"],
                                LIKETrendUserNickname: @"宋慈玉",
                                LIKETrendUserGender: @NO,
                                LIKETrendUserAge: @(25),
                                LIKETrendTimeline: [NSDate date],
                                LIKETrendUserLocation: @"上海",
                                LIKETrendContentImageURL: [NSURL URLWithString:@"http://7xjljl.com1.z0.glb.clouddn.com/f06ec084-198d-11e5-bb92-00163e004f70"],
                                LIKETrendContentText: @"有人一块看电影么,人家最近有空哦~"
                                };
        
        [_trends addObject:text1];
        [_trends addObject:text2];
        [_trends addObject:text3];
    }
    return _trends;
}

#pragma mark - api methods



@end
