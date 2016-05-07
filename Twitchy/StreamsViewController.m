//
//  SecondViewController.m
//  Twitchy
//
//  Created by James Eunson on 1/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "StreamsViewController.h"
#import "TwitchAPIClient.h"
#import "StreamCollectionViewCell.h"
#import "SectionHeaderReusableView.h"
#import "GameStreamsLoadingMoreCollectionViewCell.h"
#import "StreamWatchViewController.h"

@import AVKit;

#define kStreamCellReuseIdentifier @"streamCellReuseIdentifier"
#define kGameStreamsViewMoreCellReuseIdentifier @"gameStreamsViewMoreCellReuseIdentifier"
#define kHeaderReuseIdentifier @"headerReuseIdentifier"

@interface StreamsViewController ()

@property (nonatomic, strong) UIActivityIndicatorView * loadingView;
@property (nonatomic, strong) NSMutableArray * streams;
@property (nonatomic, assign) BOOL streamsLoaded;

@property (nonatomic, assign) BOOL pagesRemainingToLoad;

@property (nonatomic, assign) NSInteger currentPage;

- (void)loadStreamsForPage:(NSInteger)pageNumber;

@end

@implementation StreamsViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        self.streams = [[NSMutableArray alloc] init];
        
        _streamsLoaded = NO;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadStreamsForPage:_currentPage];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"showStreamWatch"]) {
        
        StreamWatchViewController * controller = (StreamWatchViewController*) segue.destinationViewController;
        controller.stream = sender;
    }
}

#pragma mark - UICollectionViewDataSource Methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if(_streamsLoaded) {
        // If more pages to load, load additional progress cell that triggers new page load
        if(_pagesRemainingToLoad) {
            return [_streams count] + 1;
        } else {
            return [_streams count];
        }
        
    } else {
        return 0;
    }
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == [_streams count] && _pagesRemainingToLoad) {
        GameStreamsLoadingMoreCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:
                                                           kGameStreamsViewMoreCellReuseIdentifier forIndexPath:indexPath];
        [cell.loadingView startAnimating];
        return cell;
        
    } else {
        StreamCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:
                                           kStreamCellReuseIdentifier forIndexPath:indexPath];
        
        cell.stream = _streams[indexPath.row];
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == [_streams count] && [_streams count] > 0 && _pagesRemainingToLoad) {
        NSLog(@"Displaying loading cell");
        
        if(_streamsLoaded) {
            _streamsLoaded = NO;
            self.currentPage++;
            
            [self loadStreamsForPage:_currentPage];
        }
    }
}

- (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    SectionHeaderReusableView * view = (SectionHeaderReusableView*)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderReuseIdentifier forIndexPath:indexPath];
    
    if(_gameFilter) {
        view.titleLabel.text = _gameFilter.name;
        
    } else {
        view.titleLabel.text = @"All Channels";
    }
    
    return view;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == [_streams count]) {
        
        if(_streamsLoaded) {
            return CGSizeMake(1800.0f, 60.0f);
        } else {
            return CGSizeZero;
        }
        
    } else {
        return CGSizeMake(kStreamCollectionViewCellWidth, kStreamCollectionViewCellHeight);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(70.0f, 60.0f, 20.0f, 60.0f);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 60.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 60.0f;
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    TwitchStream * selectedStream = self.streams[indexPath.row];
    [self performSegueWithIdentifier:@"showStreamWatch" sender:selectedStream];
    
//    [selectedStream presentStreamInViewController:self];
}

#pragma mark - Private Methods
- (void)loadStreamsForPage:(NSInteger)pageNumber {
    
    [_loadingView startAnimating];
    
    if(_existingStreams) {
        
        [self.streams addObjectsFromArray:_existingStreams];
        [self.collectionView reloadData];
        
        [_loadingView stopAnimating];
        
    } else {
        
        [[TwitchAPIClient sharedClient] loadTopStreamsWithGameFilter:_gameFilter withPageNumber:pageNumber withCompletion:^(NSArray *result, BOOL pagesRemaining) {
            [self.streams addObjectsFromArray:result];
            
            _streamsLoaded = YES;
            _pagesRemainingToLoad = pagesRemaining;
            
            [self.collectionView reloadData];
            
            [_loadingView stopAnimating];
        }];
    }
}

@end
