//
//  LIKERegionViewController.m
//  like
//
//  Created by David Fu on 9/2/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKERegionViewController.h"

#import <SMS_SDK/SMS_SDK.h>

@interface LIKERegionViewController () {
    NSMutableData*_data;
    int _state;
    NSString* _duid;
    NSString* _token;
    NSString* _appKey;
    NSString* _appSecret;
    NSMutableArray* _areaArray;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end


@implementation LIKERegionViewController

#pragma mark -
#pragma mark Custom Methods
- (void)resetSearch
{
    NSMutableDictionary *allNamesCopy = [self.allNames mutableDeepCopy];
    self.names = allNamesCopy;
    NSMutableArray *keyArray = [[NSMutableArray alloc] init];
    [keyArray addObject:UITableViewIndexSearch];
    [keyArray addObjectsFromArray:[[self.allNames allKeys]
                                   sortedArrayUsingSelector:@selector(compare:)]];
    self.keys = keyArray;
}

- (void)handleSearchForTerm:(NSString *)searchTerm
{
    NSMutableArray *sectionsToRemove = [[NSMutableArray alloc] init];
    [self resetSearch];
    
    for (NSString *key in self.keys) {
        NSMutableArray *array = [self.names valueForKey:key];
        NSMutableArray *toRemove = [[NSMutableArray alloc] init];
        for (NSString *name in array) {
            if ([name rangeOfString:searchTerm
                            options:NSCaseInsensitiveSearch].location == NSNotFound)
                [toRemove addObject:name];
        }
        if ([array count] == [toRemove count])
            [sectionsToRemove addObject:key];
        [array removeObjectsInArray:toRemove];
    }
    [self.keys removeObjectsInArray:sectionsToRemove];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"country"
                                                     ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc]
                          initWithContentsOfFile:path];
    self.allNames = dict;
    
    [self resetSearch];
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointMake(0.0, 44.0) animated:NO];
}

-(void)setAreaArray:(NSMutableArray*)array
{
    _areaArray = [NSMutableArray arrayWithArray:array];
}

-(void)clickLeftButton
{
    [self dismissViewControllerAnimated:YES completion:^{
        ;
    }];
}

#pragma mark - life cycle

#pragma mark - delegate methods

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.keys count];
    
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    if ([self.keys count] == 0)
        return 0;
    
    NSString *key = [self.keys objectAtIndex:section];
    NSArray *nameSection = [self.names objectForKey:key];
    return [nameSection count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    NSString *key = [self.keys objectAtIndex:section];
    NSArray *nameSection = [self.names objectForKey:key];
    
    static NSString *SectionsTableIdentifier = @"SectionsTableIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SectionsTableIdentifier ];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier: SectionsTableIdentifier ];
    }
    
    NSString* str1 = [nameSection objectAtIndex:indexPath.row];
    NSRange range = [str1 rangeOfString:@"+"];
    NSString* str2 = [str1 substringFromIndex:range.location];
    NSString* areaCode = [str2 stringByReplacingOccurrencesOfString:@"+" withString:@""];
    NSString* countryName = [str1 substringToIndex:range.location];
    
    cell.textLabel.text = countryName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"+%@",areaCode];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([self.keys count] == 0)
        return nil;
    NSString *key = [self.keys objectAtIndex:section];
    if (key == UITableViewIndexSearch)
        return nil;
    
    return key;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (isSearching)
        return nil;
    return self.keys;
}

#pragma mark UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    self.searchBar.text = @"";
    isSearching = NO;
    [tableView reloadData];
    return indexPath;
}
- (NSInteger)tableView:(UITableView *)tableView
sectionForSectionIndexTitle:(NSString *)title
               atIndex:(NSInteger)index
{
    NSString *key = [self.keys objectAtIndex:index];
    if (key == UITableViewIndexSearch)
    {
        [tableView setContentOffset:CGPointZero animated:NO];
        return NSNotFound;
    }
    else return index;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    NSString *key = [self.keys objectAtIndex:section];
    NSArray *nameSection = [self.names objectForKey:key];
    
    NSString* str1 = [nameSection objectAtIndex:indexPath.row];
    NSRange range = [str1 rangeOfString:@"+"];
    NSString* str2 = [str1 substringFromIndex:range.location];
    NSString* areaCode = [str2 stringByReplacingOccurrencesOfString:@"+" withString:@""];
    NSString* countryName = [str1 substringToIndex:range.location];
    
    CountryAndAreaCode* country = [[CountryAndAreaCode alloc] init];
    country.countryName = countryName;
    country.areaCode = areaCode;
    
    NSLog(@"%@ %@",countryName,areaCode);
    
    [self.view endEditing:YES];
    
    int compareResult = 0;
    
    for (int i=0; i<_areaArray.count; i++)
    {
        NSDictionary* dict1 = [_areaArray objectAtIndex:i];
        
        [dict1 objectForKey:areaCode];
        NSString* code1 = [dict1 valueForKey:@"zone"];
        if ([code1 isEqualToString:areaCode])
        {
            compareResult = 1;
            break;
        }
    }
    
    if (!compareResult) {
        [PSTAlertController presentDismissableAlertWithTitle:NSLocalizedStringFromTable(@"prompt", LIKELocalizeMain, nil)
                                                     message:NSLocalizedStringFromTable(@"prompt.doesNotSupportArea", LIKELocalizeAccount, nil)
                                                  controller:self];
        return;
    }
    
    //传递数据
    if ([self.delegate respondsToSelector:@selector(setCountryAndAreaCode:)]) {
        [self.delegate setCountryAndAreaCode:country];
    }
    
    //关闭当前
    [self clickLeftButton];
}

#pragma mark UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *searchTerm = [searchBar text];
    [self handleSearchForTerm:searchTerm];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    isSearching = YES;
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchTerm
{
    if ([searchTerm length] == 0)
    {
        [self resetSearch];
        [self.tableView reloadData];
        return;
    }
    
    [self handleSearchForTerm:searchTerm];
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    isSearching = NO;
    self.searchBar.text = @"";
    
    [self resetSearch];
    [self.tableView reloadData];
    
    [searchBar resignFirstResponder];
}

#pragma mark - event response

- (IBAction)backButtonClick:(id)sender {
    [self performSegueWithIdentifier:@"cancelChooseCountrySegue" sender:self];
}

#pragma mark - private methods

#pragma mark - accessor methods

#pragma mark - api methods

@end
