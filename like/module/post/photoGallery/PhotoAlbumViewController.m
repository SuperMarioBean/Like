//
//  PhotoAlbumViewController.m
//  Like App
//
//  Created by Quan Changjun on 14/11/3.
//  Copyright (c) 2014年 S.K. All rights reserved.
//

#import "PhotoAlbumViewController.h"
#import "PhotoAlbumCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "PhotoGellaryViewController.h"

@interface PhotoAlbumViewController()
@property (nonatomic,strong) NSMutableArray* assetGroups;
@property (nonatomic,strong) ALAssetsLibrary *assetsLibrary;

@property (readwrite, nonatomic, strong) NSIndexPath *selectedIndexPath;
@end

@implementation PhotoAlbumViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    void(^assetGroupEnumerator)(ALAssetsGroup*, BOOL *)=^(ALAssetsGroup* group, BOOL* stop){
        if (group != nil) {
            
            if ([group numberOfAssets]>0) {
                [self.assetGroups addObject:group];
            }
        }
        else {
            self.assetGroups = [NSMutableArray arrayWithArray:[[self.assetGroups reverseObjectEnumerator] allObjects]];
        }
    };
    self.assetGroups = [[NSMutableArray alloc] init];
    
    self.assetsLibrary = [[ALAssetsLibrary alloc]init];
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                      usingBlock:assetGroupEnumerator
                                    failureBlock:^(NSError *error) {
                                        NSLog(@"Enumerate the asset groups failed.");
                                    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.tableView.contentInset = UIEdgeInsetsMake(CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) , 0, 0, 0);
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    PhotoGellaryViewController *gellary = (PhotoGellaryViewController *)segue.destinationViewController;
    gellary.group = self.assetGroups[self.selectedIndexPath.row];
    gellary.assetsLibrary = self.assetsLibrary;
}

#pragma mark - delegate methods

#pragma tableview datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.assetGroups count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 88;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PhotoAlbumCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    ALAssetsGroup* group = self.assetGroups[indexPath.row];
    UIImage* image = [UIImage imageWithCGImage:[group posterImage]];
    cell.poster.image = image;
    cell.albumName.text = [group valueForProperty:ALAssetsGroupPropertyName];
    cell.assetsCount.text = [NSString stringWithFormat:@"%li",(long)[group numberOfAssets]];
    return cell;
}

#pragma tableview delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPath = indexPath;
    [self performSegueWithIdentifier:@"photoPushUnwindSegue" sender:self];
}


#pragma mark - event response

#pragma mark - private methods

#pragma mark - accessor methods

#pragma mark - api methods

@end
