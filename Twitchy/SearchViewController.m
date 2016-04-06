//
//  SearchViewController.m
//  Twitchy
//
//  Created by James Eunson on 6/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSLog(@"searchController.searchBar.text = %@", searchController.searchBar.text);
}

@end
