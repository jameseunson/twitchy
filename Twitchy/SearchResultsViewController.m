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
#import "SectionHeaderReusableView.h"
#import "StreamsViewController.h"
#import "StreamWatchViewController.h"

#define kStreamCollectionViewCellReuseIdentifier @"streamCellReuseIdentifier"
#define kGameCollectionViewCellReuseIdentifier @"gameCellReuseIdentifier"
#define kHeaderReuseIdentifier @"headerReuseIdentifier"

@interface SearchResultsViewController ()

@property (nonatomic, strong) UIActivityIndicatorView * loadingView;

@end

@implementation SearchResultsViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        
        self.games = [[NSMutableArray alloc] init];
        self.streams = [[NSMutableArray alloc] init];
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


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"showStreamWatch"]) {
        
        StreamWatchViewController * controller = (StreamWatchViewController*) segue.destinationViewController;
        controller.stream = sender;
    }
}

#pragma mark - UICollectionViewDataSource Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(section == 0) {
        return [_games count];
        
    } else {
        return [_streams count];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        GameCollectionViewCell * cell = [_collectionView dequeueReusableCellWithReuseIdentifier:
                                         kGameCollectionViewCellReuseIdentifier forIndexPath:indexPath];
        cell.game = _games[indexPath.row];
        return cell;
        
    } else {
        
        StreamCollectionViewCell * cell = [_collectionView dequeueReusableCellWithReuseIdentifier:
                                           kStreamCollectionViewCellReuseIdentifier forIndexPath:indexPath];
        cell.stream = _streams[indexPath.row];
        return cell;
    }
}

- (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    SectionHeaderReusableView * view = (SectionHeaderReusableView*)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderReuseIdentifier forIndexPath:indexPath];
    
    if([_games count] == 0 && [_streams count] == 0) {
        view.titleLabel.text = @"";
        
    } else {
        if(indexPath.section == 0) {
            view.titleLabel.text = @"Games";
            
        } else {
            view.titleLabel.text = @"Streams";
        }
    }
    
    return view;
}

#pragma mark - UICollectionViewDelegate Methods
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 0) {
        TwitchGame * game = _games[indexPath.row];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName: @"Main" bundle:[NSBundle mainBundle]];
        StreamsViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"StreamsViewController"];
        
        controller.gameFilter = game;
        [self presentViewController:controller animated:YES completion:nil];
        
    } else {
        
        TwitchStream * stream = _streams[indexPath.row];
//        [stream presentStreamInViewController:self];
        [self performSegueWithIdentifier:@"showStreamWatch" sender:stream];
    }
}

#pragma mark - Property Override Methods
- (void)setLoading:(BOOL)loading {
    _loading = loading;
    
    if(_loading) {
        [_loadingView startAnimating];
        
    } else {
        [_loadingView stopAnimating];
    }
}

#pragma mark - UICollectionViewFlowLayoutDelegate Methods
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        return CGSizeMake(kGameCollectionViewCellWidth, kGameCollectionViewCellHeight);
        
    } else {
        return CGSizeMake(kStreamCollectionViewCellWidth, kStreamCollectionViewCellHeight);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    if(section == 0) {
        return UIEdgeInsetsMake(70.0f, 60.0f, 20.0f, 60.0f);
        
    } else {
        return UIEdgeInsetsMake(70.0f, 60.0f, 60.0f, 60.0f);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 60.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 60.0f;
}

- (NSIndexPath*)indexPathForPreferredFocusedViewInCollectionView:(UICollectionView *)collectionView {
    return [NSIndexPath indexPathForItem:0 inSection:0];
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

#pragma mark - SearchViewControllerResultsDelegate Methods
- (void)searchViewControllerShouldClearExistingResults:(SearchViewController*)controller {
    
    [self.games removeAllObjects];
    [self.streams removeAllObjects];
    
    [self.collectionView reloadData];
}
- (void)searchViewController:(SearchViewController*)controller didRetrieveGamesResults:(NSArray*)results {
    
    [self.games addObjectsFromArray:results];
    [self.collectionView reloadData];
}
- (void)searchViewController:(SearchViewController*)controller didRetrieveStreamsResults:(NSArray*)results {
    
    [self.streams addObjectsFromArray:results];
    [self.collectionView reloadData];
}
- (void)searchViewControllerDidBeginLoading:(SearchViewController*)controller {
    
    self.loading = YES;
}
- (void)searchViewControllerDidEndLoading:(SearchViewController*)controller {
    
    self.loading = NO;
}

@end
