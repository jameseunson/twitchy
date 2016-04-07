//
//  SearchViewController.h
//  Twitchy
//
//  Created by James Eunson on 6/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchResultsViewController.h"

@protocol SearchViewControllerResultsDelegate;
@interface SearchViewController : UIViewController <UISearchResultsUpdating>

@property (nonatomic, assign) __unsafe_unretained id<SearchViewControllerResultsDelegate> delegate;

@end

@protocol SearchViewControllerResultsDelegate <NSObject>
@required
- (void)searchViewController:(SearchViewController*)controller didRetrieveGamesResults:(NSArray*)results;
- (void)searchViewController:(SearchViewController*)controller didRetrieveStreamsResults:(NSArray*)results;
- (void)searchViewControllerShouldClearExistingResults:(SearchViewController*)controller;
- (void)searchViewControllerDidBeginLoading:(SearchViewController*)controller;
- (void)searchViewControllerDidEndLoading:(SearchViewController*)controller;
@end