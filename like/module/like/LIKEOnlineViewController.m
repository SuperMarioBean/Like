//
//  LIKELatestViewController.m
//  like
//
//  Created by David Fu on 6/23/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKEOnlineViewController.h"

#import "LIKEOnlineCollectionViewCell.h"

static NSString *const LIKECollectionViewCellIdentifier = @"com.trinity.like.online.cell";
static NSString *const LIKECollectionViewHeaderIdentifier = @"com.trinity.like.online.header";
static NSString *const LIKECollectionViewFooterIdentifier = @"com.trinity.like.online.footer";

@interface LIKEOnlineViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *onlineLayout;

@property (readwrite, nonatomic, strong) NSMutableArray *onlines;
@property (readwrite, nonatomic, strong) NSMutableArray *nearbys;
@property (readwrite, nonatomic, strong) NSMutableArray *mirrorArray;
@property (readwrite, nonatomic)         BOOL isNearbyData;

@property(strong, nonatomic) CLLocation* location;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLocation:) name:LIKELocationCoordinateSuccessNotification object:nil];
    
    self.location = [[CLLocation alloc] init];
    
//    data init
    self.nearbys = [NSMutableArray array];
    self.onlines = [NSMutableArray array];
    self.isNearbyData = YES;
    self.mirrorArray = self.nearbys;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.isNearbyData) {
        [[LIKELocationManager sharedInstance] startForceLocating];
    }
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
    return self.mirrorArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:LIKECollectionViewCellIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell object:self.mirrorArray[indexPath.item] indexPath:indexPath];
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
    
    [self configureReusableView:reusableView kind:kind object:self.mirrorArray[indexPath.item] indexPath:indexPath];
    return reusableView;
}

#pragma mark UICollectionViewDelegateFlowLayout

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    CGSize size = [collectionView ar_sizeForCellWithIdentifier:LIKECollectionViewCellIdentifier
//                                                     indexPath:indexPath
//                                                    fixedWidth:CGRectGetWidth(self.collectionView.frame)
//                                                 configuration:^(id cell) {
//                                                     [self configureCell:cell
//                                                                  object:self.mirrorArray[indexPath.section]
//                                                               indexPath:indexPath];
//                                                 }];
//    
//    return size;
//}

#pragma mark - event response

- (void)configureCell:(UICollectionViewCell *)collectionViewCell object:(id)object indexPath:(NSIndexPath *)indexPath{
    LIKEOnlineCollectionViewCell *cell = (LIKEOnlineCollectionViewCell *)collectionViewCell;
    NSDictionary *userInfo = (NSDictionary *)object;
    NSString* avatorUrl = [NSString stringWithFormat:@"%@%@",LIKEImageBaseURL,userInfo[LIKEUserAvatorURL]];
    [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:avatorUrl]];
    cell.genderLabel.text = [userInfo[LIKEUserGender] isEqualToString:LIKEUserGenderMale]? LIKEUserGenderMaleChar: LIKEUserGenderFemaleChar;
    cell.genderLabel.backgroundColor = [userInfo[LIKEUserGender] isEqualToString:LIKEUserGenderMale]? [UIColor blueColor]: [UIColor magentaColor];
    float distance = [userInfo[LIKEUserDistance] floatValue];
    cell.distanceLabel.text = [NSString stringWithFormat:@"%.2f km",distance/1000];
    LIKEOnlineWidgetType type = LIKEOnlineWidgetTypeNone;
    
//    if ([userInfo[LIKEOnlineUserHot] boolValue]) {
//        type = type | LIKEOnlineWidgetTypeHot;
//    }
    
    if ([userInfo[LIKEUserVerify] boolValue]) {
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

//- (NSMutableArray *)onlines {
//    if (!_onlines) {
//        _onlines = [NSMutableArray array];
//        NSDictionary *text1 = @{LIKEOnlineUserAvatarURL: [NSURL URLWithString:@"http://7xjvx7.com1.z0.glb.clouddn.com/m9.png"],
//                                LIKEOnlineUserGender: @YES,
//                                LIKEOnlineUserHot: @YES,
//                                LIKEOnlineUserVerify: @YES,
//                                LIKEOnlineUserSaying: @"出去耍",
//                                };
//        NSDictionary *text2 = @{LIKEOnlineUserAvatarURL: [NSURL URLWithString:@"http://7xjvx7.com1.z0.glb.clouddn.com/f4.png"],
//                                LIKEOnlineUserGender: @YES,
//                                LIKEOnlineUserHot: @NO,
//                                LIKEOnlineUserVerify: @YES,
//                                LIKEOnlineUserSaying: @"今天遇到一个不错的男生,可惜错过了,希望下次不会有下次,大家也都要抓住机会,不要放过",
//                                };
//        NSDictionary *text3 = @{LIKEOnlineUserAvatarURL: [NSURL URLWithString:@"http://7xjvx7.com1.z0.glb.clouddn.com/f6.png"],
//                                LIKEOnlineUserGender: @NO,
//                                LIKEOnlineUserHot: @YES,
//                                LIKEOnlineUserVerify: @NO,
//                                LIKEOnlineUserSaying: @"有人一块看电影么,人家最近有空哦~",
//                                };
//        
//        for (unsigned int index = 0; index < 50; index++) {
//            NSInteger mod = index % 3;
//            if (mod == 0) {
//                [_onlines addObject:text1];
//            }
//            else if (mod == 1) {
//                [_onlines addObject:text2];
//            }
//            else if (mod == 2) {
//                [_onlines addObject:text3];
//            }
//        }
//    }
//    return _onlines;
//}

#pragma mark - Location methods
- (void)updateLocation:(NSNotification *)notification {
    NSLog(@"%@",notification.userInfo);
    NSDictionary* userInfo = notification.userInfo;
    float lat = [[userInfo objectForKey:LIKELocationCoordinateLatitudeKey] floatValue];
    float lon = [[userInfo objectForKey:LIKELocationCoordinateLongitudeKey] floatValue];
    
    CLLocation* newLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
//    if ([newLocation distanceFromLocation:self.location]>500) {
    if (YES) {
        self.location = newLocation;
        NSString* param = [NSString stringWithFormat:@"%f|%f",lat,lon];
        [geo updateUserLocation:param success:^(id responseObject) {
            NSLog(@"%@",responseObject);
            NSError* error;
            [LIKEHelper dataWithResponceObject:responseObject error:&error];
            if (!error) {
                [geo searchUsers:@{} page:1 success:^(id responseObject) {
                    NSError* error;
                    NSArray* data = [LIKEHelper dataWithResponceObject:responseObject error:&error];
                    [self.nearbys removeAllObjects];
                    [self.nearbys addObjectsFromArray:data];
                    [self.collectionView reloadData];
                    NSLog(@"%@",self.nearbys);
                } failure:^(NSError *error) {
                    NSLog(@"======get nearby users error======\n%@",error);
                }];
            }else
            {
                NSLog(@"======Upload location error======\n%@",error);
            }
        } failure:^(NSError *error) {
            NSLog(@"%@",error);
        }];
    }
}

#pragma mark - api methods


@end
