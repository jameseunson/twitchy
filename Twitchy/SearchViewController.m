//
//  SearchViewController.m
//  Twitchy
//
//  Created by James Eunson on 6/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "SearchViewController.h"
#import "TwitchAPIClient.h"

static NSTimeInterval kSearchDelay = 1.0;

@interface SearchViewController ()

@property (nonatomic, assign) BOOL pendingSearchOperation;
@property (nonatomic, strong) NSString * pendingSearchQuery;

@property (nonatomic, strong) NSString * activeQuery;
@property (nonatomic, assign, getter = isLoading) BOOL loading;

- (void)query:(NSString*)query;

@end

@implementation SearchViewController

- (instancetype)init {
    self = [super init];
    if(self) {
        
        self.loading = NO;
        _pendingSearchOperation = NO;
    }
    return self;
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    UISearchBar * searchBar = searchController.searchBar;
    NSString * query = searchBar.text;
    
    if([query isEqualToString:self.activeQuery]) {
        return;
    }
    
    if(_pendingSearchOperation) {
        [NSObject cancelPreviousPerformRequestsWithTarget:
         self selector:@selector(query:) object:_pendingSearchQuery];
        
        _pendingSearchQuery = nil;
        _pendingSearchOperation = NO;
    }
    
    [self performSelector:@selector(query:) withObject:query afterDelay:kSearchDelay];
    
    _pendingSearchOperation = YES;
    _pendingSearchQuery = query;
}

- (void)query:(NSString *)query {
    
    if(self.loading) return;
    
    // If the passed query is not present the request is malformed, return
    if((!query || query.length == 0)) return;
    
    self.loading = YES;
    
    if(![self.activeQuery isEqualToString:query]) {
        
        if([self.delegate respondsToSelector:@selector(searchViewControllerShouldClearExistingResults:)]) {
            [self.delegate performSelector:@selector(searchViewControllerShouldClearExistingResults:) withObject:self];
        }
    }

    NSLog(@"SearchViewController, query = %@", query);
    self.activeQuery = query;
    
    __block NSInteger resultsToLoad = 2;
    void (^resultsCompletion)(void) = ^(void){
        self.loading = NO;
    };
    
    [[TwitchAPIClient sharedClient] searchGamesWithQuery:query withCompletion:^(NSArray *result) {
        NSLog(@"searchController, searchGamesWithQuery, result: %@", result);
        
        if(result) {
            if([self.delegate respondsToSelector:@selector(searchViewController:didRetrieveGamesResults:)]) {
                [self.delegate performSelector:@selector(searchViewController:didRetrieveGamesResults:)
                                    withObject:self withObject:result];
            }
        }
        
        resultsToLoad--;
        if(resultsToLoad <= 0) {
            resultsCompletion();
        }
    }];
    [[TwitchAPIClient sharedClient] searchStreamsWithQuery:query withCompletion:^(NSArray *result) {
        NSLog(@"searchController, searchStreamsWithQuery, result: %@", result);
        
        if(result) {
            if([self.delegate respondsToSelector:@selector(searchViewController:didRetrieveStreamsResults:)]) {
                [self.delegate performSelector:@selector(searchViewController:didRetrieveStreamsResults:)
                                    withObject:self withObject:result];
            }
        }
        
        resultsToLoad--;
        if(resultsToLoad <= 0) {
            resultsCompletion();
        }
    }];
}

#pragma mark - Property Override Methods
- (void)setLoading:(BOOL)loading {
    _loading = loading;
    
    if(_loading) {
        if([self.delegate respondsToSelector:@selector(searchViewControllerDidBeginLoading:)]) {
            [self.delegate performSelector:@selector(searchViewControllerDidBeginLoading:) withObject:self];
        }
        
    } else {
        if([self.delegate respondsToSelector:@selector(searchViewControllerDidEndLoading:)]) {
            [self.delegate performSelector:@selector(searchViewControllerDidEndLoading:) withObject:self];
        }
    }
}

@end
