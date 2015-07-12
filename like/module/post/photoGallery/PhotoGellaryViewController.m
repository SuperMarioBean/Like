//
//  PhotoGellalryViewController.m
//  Like App
//
//  Created by Quan Changjun on 14/11/3.
//  Copyright (c) 2014年 S.K. All rights reserved.
//

#import "PhotoGellaryViewController.h"
#import "PhotoGellaryCell.h"
#import "PhotoGellaryHeader.h"
#import "PhotoAlbumViewController.h"

@interface PhotoGellaryViewController()<UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) NSMutableArray* assets;

@property (readwrite, nonatomic, strong) UIViewController<PhotoGellaryViewControllerProtocol> *parent;

@end

@implementation PhotoGellaryViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.parent = (UIViewController<PhotoGellaryViewControllerProtocol> *)self.parentViewController;
    
    self.assets = [[NSMutableArray alloc] init];
    void(^assetsEnumerator)(ALAsset *, NSUInteger , BOOL *)=^(ALAsset *result, NSUInteger index, BOOL *stop){
        if (result) {
            [self.assets addObject:result];
        }
        else {
            self.assets = (NSMutableArray*)[[self.assets reverseObjectEnumerator] allObjects];
            [self p_likeSetImageToParent:0];
            [self.collectionView reloadData];
            if (!self.parent.isFireOpen) {
                [self.collectionView setContentOffset:CGPointMake(0, 44) animated:YES];
            }
        }
    };
    
    void(^assetGroupEnumerator)(ALAssetsGroup*, BOOL *)=^(ALAssetsGroup* group, BOOL* stop){
        if (group) {
            self.group = group;
            [self.group enumerateAssetsUsingBlock:assetsEnumerator];
        }
    };
    
    if (!self.group) {
        self.assetsLibrary = [[ALAssetsLibrary alloc] init];
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                          usingBlock:assetGroupEnumerator
                                        failureBlock:^(NSError *error) {
                                            NSLog(@"Enumerate the asset groups failed.");
                                        }];
    }
    else {
        [self.group enumerateAssetsUsingBlock:assetsEnumerator];
    }
}

#pragma mark - delegate methods

#pragma UICollectionViewDatasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.assets count];
}

- (UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoGellaryCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    ALAsset* asset = (ALAsset*)[self.assets objectAtIndex:indexPath.row];
    cell.thumnail.image = [UIImage imageWithCGImage:[asset thumbnail]];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = self.collectionView.frame.size.width;
    width = floorf(width/3);
    return CGSizeMake(width, width);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    PhotoGellaryHeader *cell = [collectionView dequeueReusableSupplementaryViewOfKind:
                                UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
    cell.title.text = [self.group valueForProperty:ALAssetsGroupPropertyName];
    
    return cell;
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self p_likeSetImageToParent:indexPath.row];
}

#pragma mark - event response

- (IBAction)btnBack:(id)sender {
    [self performSegueWithIdentifier:@"photoPopSegue" sender:self];
}

- (IBAction)photoPopUnwind:(UIStoryboardSegue *)sender {
    
}

#pragma mark - private methods

- (void)p_likeSetImageToParent:(NSInteger)index {
    ALAsset * asset = [self.assets objectAtIndex:index];
    [self.parent setImageCropWithImage:[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage
                                                           scale:1.0f
                                                     orientation:UIImageOrientationUp]];
}

#pragma mark - accessor methods

#pragma mark - api methods


@end
