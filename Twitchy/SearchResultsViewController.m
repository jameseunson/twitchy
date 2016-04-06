//
//  SearchResultsViewController.m
//  Twitchy
//
//  Created by James Eunson on 6/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "SearchResultsViewController.h"
#import "StreamCollectionViewCell.h"
#import "GameCollectionViewCell.h"
#import "TwitchFeaturedStreamListing.h"

#define kStreamCollectionViewCellReuseIdentifier @"streamCellReuseIdentifier"
#define kGameCollectionViewCellReuseIdentifier @"gameCellReuseIdentifier"

@interface SearchResultsViewController ()

@property (nonatomic, strong) UIActivityIndicatorView * loadingView;

@property (nonatomic, strong) NSMutableArray * games;
@property (nonatomic, strong) NSMutableArray * streams;

@property (nonatomic, assign) BOOL gamesLoaded;
@property (nonatomic, assign) BOOL streamsLoaded;

@end

@implementation SearchResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)loadView {
    [super loadView];
    
    self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                        UIActivityIndicatorViewStyleWhiteLarge];
    _loadingView.color = [UIColor darkGrayColor];
    _loadingView.center = self.view.center;
    [self.view addSubview:_loadingView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(section == 0) {
        if(_streamsLoaded) {
            return [_streams count];
            
        } else {
            return 0;
        }
        
    } else {
        
        if(_gamesLoaded) {
            return [_games count];
            
        } else {
            return 0;
        }
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        
        StreamCollectionViewCell * cell = [_collectionView dequeueReusableCellWithReuseIdentifier:
                                           kStreamCollectionViewCellReuseIdentifier forIndexPath:indexPath];
        
        TwitchFeaturedStreamListing * listing = _streams[indexPath.row];
        cell.stream = listing.stream;
        
        return cell;
        
    } else {
        
        GameCollectionViewCell * cell = [_collectionView dequeueReusableCellWithReuseIdentifier:
                                         kGameCollectionViewCellReuseIdentifier forIndexPath:indexPath];
        cell.gameListing = _games[indexPath.row];
        return cell;
    }
}

@end
