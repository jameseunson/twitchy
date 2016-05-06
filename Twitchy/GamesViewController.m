//
//  FirstViewController.m
//  Twitchy
//
//  Created by James Eunson on 1/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "GamesViewController.h"
#import "TwitchAPIClient.h"
#import "GameCollectionViewCell.h"
#import "StreamsViewController.h"
#import "GameStreamsLoadingMoreCollectionViewCell.h"
#import "SectionHeaderReusableView.h"

#define kGameCellReuseIdentifier @"gameCellReuseIdentifier"
#define kGameStreamsViewMoreCellReuseIdentifier @"gameStreamsViewMoreCellReuseIdentifier"
#define kHeaderReuseIdentifier @"headerReuseIdentifier"

@interface GamesViewController ()

@property (nonatomic, strong) UIActivityIndicatorView * loadingView;
@property (nonatomic, strong) NSMutableArray * games;

@property (nonatomic, assign) BOOL gamesLoaded;
@property (nonatomic, assign) BOOL pagesRemainingToLoad;

@property (nonatomic, assign) NSInteger currentPage;

- (void)loadGamesForPage:(NSInteger)pageNumber;

@end

@implementation GamesViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        self.games = [[NSMutableArray alloc] init];
        
        _gamesLoaded = NO;
        _pagesRemainingToLoad = NO;
        
        _currentPage = 0;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                        UIActivityIndicatorViewStyleWhiteLarge];
    _loadingView.color = [UIColor darkGrayColor];
    _loadingView.center = self.view.center;
    [self.view addSubview:_loadingView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self loadGamesForPage:_currentPage];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if(_gamesLoaded) {
        return [_games count] + 1;
        
    } else {
        return 0;
    }
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == [_games count] && _pagesRemainingToLoad) {
        GameStreamsLoadingMoreCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:
                                         kGameStreamsViewMoreCellReuseIdentifier forIndexPath:indexPath];
        [cell.loadingView startAnimating];
        return cell;
        
    } else {
        GameCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:
                                         kGameCellReuseIdentifier forIndexPath:indexPath];
        
        cell.gameListing = _games[indexPath.row];
        return cell;
    }
}

- (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    SectionHeaderReusableView * view = (SectionHeaderReusableView*)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderReuseIdentifier forIndexPath:indexPath];
    
    view.titleLabel.text = @"All Games";
    
    return view;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == [_games count] && [_games count] > 0 && _pagesRemainingToLoad) {
        
        if(_gamesLoaded) {
            _gamesLoaded = NO;
            self.currentPage++;
            
            [self loadGamesForPage:_currentPage];
        }
    }
}

- (NSIndexPath*)indexPathForPreferredFocusedViewInCollectionView:(UICollectionView *)collectionView {
    return [NSIndexPath indexPathForItem:(_currentPage * 25) inSection:0];
}

- (BOOL)collectionView:(UICollectionView *)collectionView canFocusItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldUpdateFocusInContext:(UICollectionViewFocusUpdateContext *)context {
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - UICollectionViewFlowLayoutDelegate Methods
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == [_games count]) {

        if(_gamesLoaded) {
            return CGSizeMake(1800.0f, 60.0f);
        } else {
            return CGSizeZero;
        }

    } else {
        return CGSizeMake(kGameCollectionViewCellWidth, kGameCollectionViewCellHeight);
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"showStreams"]) {
        
        NSArray * items = [self.collectionView indexPathsForSelectedItems];
        NSIndexPath * indexPath = [items firstObject];
        
        TwitchGameListing * gameListing = _games[indexPath.row];
        
        StreamsViewController * controller = [segue destinationViewController];
        controller.gameFilter = gameListing.game;
    }
}

- (void)loadGamesForPage:(NSInteger)pageNumber {
    [_loadingView startAnimating];
    
    [[TwitchAPIClient sharedClient] loadTopGamesWithPageNumber:pageNumber withCompletion:^(NSArray *result, BOOL pagesRemaining) {
        
        [self.games addObjectsFromArray:result];
        _gamesLoaded = YES;
        _pagesRemainingToLoad = pagesRemaining;
        
        [self.collectionView reloadData];
        
        [_loadingView stopAnimating];
    }];
}

@end
