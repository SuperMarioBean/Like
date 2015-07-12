//
//  LIKEFilterViewController.m
//  like
//
//  Created by David Fu on 7/10/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKEFilterViewController.h"

#import "SCSwipeableFilterView.h"
#import "LIKEFilterCollectionViewCell.h"

@interface LIKEFilterViewController () <SCSwipeableFilterViewDelegate,
                                        UICollectionViewDataSource,
                                        UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet SCSwipeableFilterView *swipeableFilterView;

@property (weak, nonatomic) IBOutlet UICollectionView *filtersCollectionView;

@property (readwrite, nonatomic, copy) NSArray *filtersArray;

@property (readwrite, nonatomic, strong) NSMutableArray *cacheThumbnailImagesArray;

@property (readwrite, nonatomic, strong) CIImage *thumbnail;

@end

@implementation LIKEFilterViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.filtersArray = @[[SCFilter emptyFilter],
                          [SCFilter filterWithCIFilterName:@"CIPhotoEffectNoir"],
                          [SCFilter filterWithCIFilterName:@"CIPhotoEffectChrome"],
                          [SCFilter filterWithCIFilterName:@"CIPhotoEffectInstant"],
                          [SCFilter filterWithCIFilterName:@"CIPhotoEffectTonal"],
                          [SCFilter filterWithCIFilterName:@"CIPhotoEffectFade"]
                          ];

    self.swipeableFilterView.filters = self.filtersArray;
    self.swipeableFilterView.delegate = self;
    [self.swipeableFilterView setImageByUIImage:self.image];
    
    UIImage *image = [self.image thumbnailImage:90
                              transparentBorder:0
                                   cornerRadius:0
                           interpolationQuality:kCGInterpolationHigh];
    
    self.cacheThumbnailImagesArray = [NSMutableArray arrayWithObjects:image, nil];
    self.thumbnail = [CIImage imageWithCGImage:image.CGImage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *identifier = segue.identifier;
    if ([identifier isEqualToString:@"addTagsSegue"]) {
        UIViewController<LIKETransferProcessedImageProtocol> *viewController = segue.destinationViewController;
        [viewController setImage:self.swipeableFilterView.processedUIImage];
    }
}

#pragma mark - delegate methods

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filtersArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    [self configureCell:cell object:self.filtersArray[indexPath.item] indexPath:indexPath];
    return cell;
}

#pragma mark UICollectionViewDelegateFlowLayout

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.swipeableFilterView scrollToFilter:self.filtersArray[indexPath.item] animated:NO];
    [self.filtersCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

#pragma mark SCSwipeableFilterViewDelegate

- (void)swipeableFilterView:(SCSwipeableFilterView *__nonnull)swipeableFilterView didScrollToFilter:(SCFilter *__nullable)filter {
    NSUInteger item;
    if (filter) {
        item = [self.filtersArray indexOfObject:filter];
    }
    else {
        item = 0;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
    [self.filtersCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

#pragma mark - event response

- (IBAction)next:(id)sender {
    [self performSegueWithIdentifier:@"addTagsSegue" sender:self];
}

- (void)configureCell:(UICollectionViewCell *)collectionViewCell object:(id)object indexPath:(NSIndexPath *)indexPath{
    LIKEFilterCollectionViewCell *cell = (LIKEFilterCollectionViewCell *)collectionViewCell;
    SCFilter *filter = (SCFilter *)object;
    cell.filterLabel.text = filter.name;
    
    UIImage *image = [self.cacheThumbnailImagesArray objectWithIndex:indexPath.item];
    if (!image) {
        CIImage *ciimage = [filter imageByProcessingImage:self.thumbnail];
        image = [UIImage imageWithCIImage:ciimage];
        [self.cacheThumbnailImagesArray insertObject:image atIndex:indexPath.item];
    }
    
    cell.filterImageView.image = image;
}

#pragma mark - private methods

#pragma mark - accessor methods

#pragma mark - api methods

@end
