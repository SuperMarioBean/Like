//
//  LIKELatestViewController.m
//  like
//
//  Created by David Fu on 6/23/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKEOnlineViewController.h"

#import "LIKEOnlineCollectionViewCell.h"

static NSString *const LIKEOnlineUserAvatarURL = @"userAvatarURL";
static NSString *const LIKEOnlineUserSaying = @"userSaying";
static NSString *const LIKEOnlineUserGender = @"userGender";
static NSString *const LIKEOnlineUserHot = @"userHot";
static NSString *const LIKEOnlineUserVerify = @"userVerify";

static NSString *const LIKECollectionViewCellIdentifier = @"com.trinity.like.online.cell";
static NSString *const LIKECollectionViewHeaderIdentifier = @"com.trinity.like.online.header";
static NSString *const LIKECollectionViewFooterIdentifier = @"com.trinity.like.online.footer";

@interface LIKEOnlineViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *onlineLayout;

@property (readwrite, nonatomic, strong) NSMutableArray *onlines;

@end

@implementation LIKEOnlineViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"LIKEOnlineCollectionViewCell" bundle:nil]
          forCellWithReuseIdentifier:LIKECollectionViewCellIdentifier];
    self.onlineLayout.sectionInset = UIEdgeInsetsMake(4, 4, 4, 4);
    self.onlineLayout.minimumInteritemSpacing = 4;
    self.onlineLayout.minimumLineSpacing = 4;
    CGFloat width = floorf((CGRectGetWidth(self.collectionView.frame) - 4 * 4) / 3);
    self.onlineLayout.itemSize = CGSizeMake(width, width);
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
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.onlines.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:LIKECollectionViewCellIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell object:self.onlines[indexPath.item] indexPath:indexPath];
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
    [self configureReusableView:reusableView kind:kind object:self.onlines[indexPath.item] indexPath:indexPath];
    return reusableView;
}

#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = [collectionView ar_sizeForCellWithIdentifier:LIKECollectionViewCellIdentifier
                                                     indexPath:indexPath
                                                    fixedWidth:CGRectGetWidth(self.collectionView.frame)
                                                 configuration:^(id cell) {
                                                     [self configureCell:cell
                                                                  object:self.onlines[indexPath.section]
                                                               indexPath:indexPath];
                                                 }];
    
    return size;
}

#pragma mark - event response

- (void)configureCell:(UICollectionViewCell *)collectionViewCell object:(id)object indexPath:(NSIndexPath *)indexPath{
    LIKEOnlineCollectionViewCell *cell = (LIKEOnlineCollectionViewCell *)collectionViewCell;
    NSDictionary *online = (NSDictionary *)object;
    [cell.avatarImageView sd_setImageWithURL:online[LIKEOnlineUserAvatarURL]];
    cell.sayingLabel.text = online[LIKEOnlineUserSaying];
    cell.genderLabel.text = [online[LIKEOnlineUserGender] boolValue]? LIKEUserGenderMaleChar: LIKEUserGenderFemaleChar;
    cell.genderLabel.backgroundColor = [online[LIKEOnlineUserGender] boolValue]? [UIColor blueColor]: [UIColor magentaColor];
    LIKEOnlineWidgetType type = LIKEOnlineWidgetTypeNone;
    if ([online[LIKEOnlineUserHot] boolValue]) {
        type = type | LIKEOnlineWidgetTypeHot;
    }
    
    if ([online[LIKEOnlineUserVerify] boolValue]) {
        type = type | LIKEOnlineWidgetTypeVerify;
    }
    
    cell.type = type;
}

- (void)configureReusableView:(UICollectionReusableView *)collectionReusableView kind:(NSString *)kind object:(id)object indexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {

    }
    else if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
    }
}

#pragma mark - private methods

#pragma mark - accessor methods

- (NSMutableArray *)onlines {
    if (!_onlines) {
        _onlines = [NSMutableArray array];
        NSDictionary *text1 = @{LIKEOnlineUserAvatarURL: [NSURL URLWithString:@"http://7xjvx7.com1.z0.glb.clouddn.com/m9.png"],
                                LIKEOnlineUserGender: @YES,
                                LIKEOnlineUserHot: @YES,
                                LIKEOnlineUserVerify: @YES,
                                LIKEOnlineUserSaying: @"出去耍",
                                };
        NSDictionary *text2 = @{LIKEOnlineUserAvatarURL: [NSURL URLWithString:@"http://7xjvx7.com1.z0.glb.clouddn.com/f4.png"],
                                LIKEOnlineUserGender: @YES,
                                LIKEOnlineUserHot: @NO,
                                LIKEOnlineUserVerify: @YES,
                                LIKEOnlineUserSaying: @"今天遇到一个不错的男生,可惜错过了,希望下次不会有下次,大家也都要抓住机会,不要放过",
                                };
        NSDictionary *text3 = @{LIKEOnlineUserAvatarURL: [NSURL URLWithString:@"http://7xjvx7.com1.z0.glb.clouddn.com/f6.png"],
                                LIKEOnlineUserGender: @NO,
                                LIKEOnlineUserHot: @YES,
                                LIKEOnlineUserVerify: @NO,
                                LIKEOnlineUserSaying: @"有人一块看电影么,人家最近有空哦~",
                                };
        
        for (unsigned int index = 0; index < 50; index++) {
            NSInteger mod = index % 3;
            if (mod == 0) {
                [_onlines addObject:text1];
            }
            else if (mod == 1) {
                [_onlines addObject:text2];
            }
            else if (mod == 2) {
                [_onlines addObject:text3];
            }
        }
    }
    return _onlines;
}

#pragma mark - api methods


@end
