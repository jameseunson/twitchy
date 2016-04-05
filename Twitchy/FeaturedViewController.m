//
//  FeaturedViewController.m
//  Twitchy
//
//  Created by James Eunson on 4/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "FeaturedViewController.h"

#import "StreamCollectionViewCell.h"
#import "GameCollectionViewCell.h"
#import "TwitchAPIClient.h"
#import "TwitchFeaturedStreamListing.h"
#import "SectionHeaderReusableView.h"
#import "FeaturedViewMoreCollectionViewCell.h"
#import "StreamsViewController.h"

#define kStreamCollectionViewCellReuseIdentifier @"streamCellReuseIdentifier"
#define kGameCollectionViewCellReuseIdentifier @"gameCellReuseIdentifier"
#define kFeaturedViewMoreCellReuseIdentifier @"featuredViewMoreCellReuseIdentifier"
#define kHeaderReuseIdentifier @"headerReuseIdentifier"

@interface FeaturedViewController ()

@property (nonatomic, strong) UIActivityIndicatorView * loadingView;

@property (nonatomic, strong) NSMutableArray * games;

@property (nonatomic, strong) NSMutableArray * allStreams;
@property (nonatomic, strong) NSMutableArray * streams;

@property (nonatomic, assign) BOOL gamesLoaded;
@property (nonatomic, assign) BOOL streamsLoaded;

- (void)presentAllFeaturedStreams;

@end

@implementation FeaturedViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        
        self.games = [[NSMutableArray alloc] init];
        
        self.allStreams = [[NSMutableArray alloc] init];
        self.streams = [[NSMutableArray alloc] init];
        
        _gamesLoaded = NO;
        _streamsLoaded = NO;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_loadingView startAnimating];
    
    [[TwitchAPIClient sharedClient] loadFeaturedStreamsWithCompletion:^(NSArray *result) {
        
        [self.allStreams addObjectsFromArray:result];
        
        if(result && [result count] >= 6) {
            result = [result subarrayWithRange:NSMakeRange(0, 6)];
        }
        
        [self.streams addObjectsFromArray:result];
        _streamsLoaded = YES;
        
        [self.collectionView reloadData];
        
        if([_loadingView isAnimating]) {
            [_loadingView stopAnimating];
        }
    }];
    
    [[TwitchAPIClient sharedClient] loadTopGamesWithCompletion:^(NSArray *result) {
        
        if(result && [result count] >= 10) {
            result = [result subarrayWithRange:NSMakeRange(0, 10)];
        }
        
        [self.games addObjectsFromArray:result];
        _gamesLoaded = YES;
        
        [self.collectionView reloadData];
        
        if([_loadingView isAnimating]) {
            [_loadingView stopAnimating];
        }
    }];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(section == 0) {
        if(_streamsLoaded) {
            return [_streams count] + 1;
            
        } else {
            return 0;
        }
        
    } else {
        
        if(_gamesLoaded) {
            return [_games count] + 1;
            
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
        
        if(indexPath.row == [_streams count]) {
            
            FeaturedViewMoreCollectionViewCell * cell = [_collectionView dequeueReusableCellWithReuseIdentifier:
                                                         kFeaturedViewMoreCellReuseIdentifier forIndexPath:indexPath];
            return cell;
            
        } else {
            
            StreamCollectionViewCell * cell = [_collectionView dequeueReusableCellWithReuseIdentifier:
                                               kStreamCollectionViewCellReuseIdentifier forIndexPath:indexPath];
            
            TwitchFeaturedStreamListing * listing = _streams[indexPath.row];
            cell.stream = listing.stream;
            
            return cell;
        }
        
    } else {
        
        if(indexPath.row == [_games count]) {
            
            FeaturedViewMoreCollectionViewCell * cell = [_collectionView dequeueReusableCellWithReuseIdentifier:
                                                         kFeaturedViewMoreCellReuseIdentifier forIndexPath:indexPath];
            return cell;
            
        } else {
            
            GameCollectionViewCell * cell = [_collectionView dequeueReusableCellWithReuseIdentifier:
                                             kGameCollectionViewCellReuseIdentifier forIndexPath:indexPath];
            cell.gameListing = _games[indexPath.row];
            return cell;
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 0) {
        
        if(indexPath.row == [_streams count]) {
            [self presentAllFeaturedStreams];
            
        } else {
            
            TwitchFeaturedStreamListing * listing = _streams[indexPath.row];
            TwitchStream * stream = listing.stream;
            [stream presentStreamInViewController:self];
        }
        
    } else {
        
        if(indexPath.row == [_games count]) {
            self.tabBarController.selectedIndex = 1;
        } else {
            // Handled by segue
        }
    }
}

- (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    SectionHeaderReusableView * view = (SectionHeaderReusableView*)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderReuseIdentifier forIndexPath:indexPath];
    
    if(indexPath.section == 0) {
        view.titleLabel.text = @"Featured Channels";
        
    } else {
        view.titleLabel.text = @"Featured Games";
    }
    
    return view;
}

#pragma mark - UICollectionViewFlowLayoutDelegate Methods
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        if(indexPath.row == [_streams count]) {
            if(_streamsLoaded) {
                return CGSizeMake(1800.0f, 60.0f);
            } else {
                return CGSizeZero;
            }
            
        } else {
            return CGSizeMake(kStreamCollectionViewCellWidth, kStreamCollectionViewCellHeight);
        }
        
    } else {
        
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

#pragma mark - UIStoryboardDelegate Methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"showFeaturedGameStreams"]) {
        
        NSArray * items = [self.collectionView indexPathsForSelectedItems];
        NSIndexPath * indexPath = [items firstObject];
        
        TwitchGameListing * gameListing = _games[indexPath.row];
        
        StreamsViewController * controller = [segue destinationViewController];
        controller.gameFilter = gameListing.game;
        
    } else if([segue.identifier isEqualToString:@"showAllFeaturedStreams"]) {
        
        NSArray * streams = (NSArray*)sender;
        
        StreamsViewController * controller = [segue destinationViewController];
        controller.existingStreams = streams;
    }
}

#pragma mark - Private Methods
- (void)presentAllFeaturedStreams {
    
    // Extract TwitchStream objects from their TwitchFeaturedStreamListing encapsulated class
    NSMutableArray * rawStreams = [[NSMutableArray alloc] init];
    
    for(TwitchFeaturedStreamListing * listing in self.allStreams) {
        [rawStreams addObject:listing.stream];
    }
    [self performSegueWithIdentifier:@"showAllFeaturedStreams" sender:rawStreams];
}

@end
