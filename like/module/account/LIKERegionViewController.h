//
//  LIKERegionViewController.h
//  like
//
//  Created by David Fu on 9/2/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <SMS_SDK/CountryAndAreaCode.h>

@protocol LIKERegionViewControllerDelegate <NSObject>
- (void)setCountryAndAreaCode:(CountryAndAreaCode *)countryAndAreaCod;
@end

@interface LIKERegionViewController : UIViewController <UISearchBarDelegate> {
    BOOL isSearching;
}

@property (nonatomic, strong) NSDictionary *allNames;
@property (nonatomic, strong) NSMutableDictionary *names;
@property (nonatomic, strong) NSMutableArray *keys;

@property (nonatomic, strong) id<LIKERegionViewControllerDelegate> delegate;

- (void)resetSearch;
- (void)handleSearchForTerm:(NSString *)searchTerm;
- (void)setAreaArray:(NSMutableArray*)array;

@end

