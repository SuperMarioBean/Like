//
//  LIKESearchTagViewController.m
//  like
//
//  Created by David Fu on 7/10/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKESearchTagViewController.h"

#import "LIKETagsViewController.h"

@interface LIKESearchTagViewController () <UITableViewDataSource,
                                           UITableViewDelegate,
                                           UISearchBarDelegate,
                                           UISearchDisplayDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (readwrite, nonatomic, strong) NSMutableArray *searchResultArray;

@property (readwrite, nonatomic, strong) NSMutableArray *localTagsArray;

@end

@implementation LIKESearchTagViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.backgroundImageView.image = self.backgroundImage;
    
    self.searchResultArray = [NSMutableArray array];
    self.localTagsArray = [LIKEAppContext sharedInstance].localTagsArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - delegate methods

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchDisplayController.searchBar resignFirstResponder];
    
    NSString * tag = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        tag = [self.searchResultArray objectAtIndex:indexPath.row];
    }else{
        tag = [self.localTagsArray objectAtIndex:indexPath.row];
    }
    
    if (![self.localTagsArray containsObject:tag]) {
        [self.localTagsArray insertObject:tag atIndex:0];
    }
    
    if ([self.delegate respondsToSelector:@selector(setTag:type:)]) {
        [self.delegate setTag:tag type:_type];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.searchResultArray count];
    }
    else {
        return [self.localTagsArray count];
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *myCell = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myCell];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myCell];
    }
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (indexPath.row == 0) {
            cell.textLabel.text = [NSString stringWithFormat:@"添加标签：%@", [self.searchResultArray objectAtIndex:indexPath.row]];
        }
        else {
            cell.textLabel.text = [self.searchResultArray objectAtIndex:indexPath.row];
        }
    }
    else {
        cell.textLabel.text = [self.localTagsArray objectAtIndex:indexPath.row];
    }
    
    return cell;
}

#pragma UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString {
    //一旦SearchBar輸入內容有變化，則執行這個方法，詢問要不要重裝searchResultTableView的數據
    
    // Return YES to cause the search result table view to be reloaded.
    //    self.searchDisplayController.searchResultsTableView.layer.opacity = 0.9f;
    
    if (searchString.length<=1) {
        self.tableView.hidden = NO;
        [self.searchResultArray removeAllObjects];
    }
    else {
        if (self.searchResultArray.count<=1) {
            [self.searchResultArray removeAllObjects];
            [self.searchResultArray addObject:searchString];
            //            if(self.type==1)
            //            {
            //                [self searchCustomTag:searchString];
            //            }else
            //            {
            //                //search location tag
            //
            //            }
            [self searchCustomTag:searchString];
            
        }
        else {
            self.tableView.hidden = YES;
            [self filterContentForSearchText:searchString scope:[self.searchDisplayController.searchBar scopeButtonTitles][self.searchDisplayController.searchBar.selectedScopeButtonIndex]];
        }
        self.tableView.hidden = YES;
    }
    
    return YES;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    return YES;
}

#pragma mark - event response

#pragma mark - private methods

- (void)addTagNotification:(NSNotification *)notification {
//    NSDictionary* obj = notification.userInfo;
//   NSDictionary* data = [obj objectForKey:@"data"];
//    if([[data objectForKey:ERROR_MESSAGE] isEqualToString:REQUEST_SUCCESS])
//    {
//        NSLog(@"addTagNotification :%@",data);
//        
//        NSArray* taglist = [data objectForKey:@"taglist"];
//        [self.searchResultArray addObjectsFromArray:taglist];
//        [self.searchDisplayController.searchResultsTableView reloadData];
//    }
}

- (void)searchCustomTag:(NSString *)searchText {
//    NSDictionary * data  = [NSDictionary dictionaryWithObjects:@[NOTIFICATION_SEARCHTAG,searchText,OP_SEARCH_TAGS] forKeys:@[NOTIFYNAME,SEARCH_KEYWORD,OPR]];
//    NSError *error = nil;
//    NSData* json = [NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObject:data forKey:@"head"] options:NSJSONWritingPrettyPrinted error:&error];
//    
//    [[SocketManager sharedManager] write:json];
}

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope {
    NSMutableArray *tempResults = [NSMutableArray array];
    NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
    
    for (int i = 0; i < self.searchResultArray.count; i++) {
        NSString *storeString = self.searchResultArray[i];
        NSRange storeRange = NSMakeRange(0, storeString.length);
        NSRange foundRange = [storeString rangeOfString:searchText options:searchOptions range:storeRange];
        if (foundRange.length) {
            [tempResults addObject:storeString];
        }
    }
    
    [self.searchResultArray removeAllObjects];
    [self.searchResultArray addObject:searchText];
    
    [self.searchResultArray addObjectsFromArray:tempResults];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    if ([self.delegate respondsToSelector:@selector(setTag:type:)]) {
        [self.delegate setTag:@"" type:_type];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - accessor methods

#pragma mark - api methods


@end
