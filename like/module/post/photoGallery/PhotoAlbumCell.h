//
//  PhotoAlbumCell.h
//  Like App
//
//  Created by Quan Changjun on 14/11/3.
//  Copyright (c) 2014年 S.K. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoAlbumCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *poster;
@property (strong, nonatomic) IBOutlet UILabel *albumName;
@property (strong, nonatomic) IBOutlet UILabel *assetsCount;
@end
