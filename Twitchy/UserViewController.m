//
//  UserViewController.m
//  Twitchy
//
//  Created by James Eunson on 6/05/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "UserViewController.h"
#import "AppConfig.h"
#import "StreamCollectionViewCell.h"
#import "GameStreamsLoadingMoreCollectionViewCell.h"
#import "SectionHeaderReusableView.h"
#import "TwitchAPIClient.h"
#import "StreamWatchViewController.h"

#define kUserStreamCellReuseIdentifier @"streamCellReuseIdentifier"
#define kUserStreamsViewMoreCellReuseIdentifier @"gameStreamsViewMoreCellReuseIdentifier"
#define kHeaderReuseIdentifier @"headerReuseIdentifier"

@interface UserViewController ()

@property (nonatomic, strong) UIActivityIndicatorView * loadingView;
@property (nonatomic, strong) NSMutableArray * userStreams;
@property (nonatomic, assign) BOOL userStreamsLoaded;

@property (nonatomic, assign) BOOL pagesRemainingToLoad;

@property (nonatomic, assign) NSInteger currentPage;

- (void)loadUserStreamsForPage:(NSInteger)pageNumber;

@end

@implementation UserViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        self.userStreams = [[NSMutableArray alloc] init];
        
        _userStreamsLoaded = NO;
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
    
    self.title = [[AppConfig sharedConfig] objectForKey:kOAuthUsername];
    
    [self loadUserStreamsForPage:_currentPage];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"showWatchSplit"]) {
        
        StreamWatchViewController * controller = (StreamWatchViewController*) segue.destinationViewController;
        controller.stream = sender;
    }
}

#pragma mark - UICollectionViewDataSource Methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if(_userStreamsLoaded) {
        
        // If more pages to load, load additional progress cell that triggers new page load
        if(_pagesRemainingToLoad) {
            return [_userStreams count] + 1;
        } else {
            return [_userStreams count];
        }
        
    } else {
        return 0;
    }
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == [_userStreams count] && _pagesRemainingToLoad) {
        GameStreamsLoadingMoreCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:
                                                           kUserStreamsViewMoreCellReuseIdentifier forIndexPath:indexPath];
        [cell.loadingView startAnimating];
        return cell;
        
    } else {
        StreamCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:
                                           kUserStreamCellReuseIdentifier forIndexPath:indexPath];
        cell.stream = _userStreams[indexPath.row];
        return cell;
    }
}

#pragma mark - UICollectionViewDelegate Methods


- (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    SectionHeaderReusableView * view = (SectionHeaderReusableView*)[collectionView dequeueReusableSupplementaryViewOfKind:
                                                                    UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderReuseIdentifier forIndexPath:indexPath];
    view.titleLabel.text = @"Followed Streams";
    
    return view;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == [_userStreams count]) {
        
        if(_userStreamsLoaded) {
            return CGSizeMake(1800.0f, 60.0f);
        } else {
            return CGSizeZero;
        }
        
    } else {
        return CGSizeMake(kStreamCollectionViewCellWidth, kStreamCollectionViewCellHeight);
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == [_userStreams count] && [_userStreams count] > 0 && _pagesRemainingToLoad) {
        NSLog(@"Displaying loading cell");
        
        if(_userStreamsLoaded) {
            _userStreamsLoaded = NO;
            self.currentPage++;
            
            [self loadUserStreamsForPage:_currentPage];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    // This is not a user stream, but the load more button
    if(indexPath.row == [_userStreams count] && [_userStreams count] > 0 && _pagesRemainingToLoad) {
        return;
    }
    
    TwitchStream * selectedStream = _userStreams[indexPath.row];
    [self performSegueWithIdentifier:@"showWatchSplit" sender:selectedStream];
}

#pragma mark - UICollectionViewDelegateFlowLayout Methods
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

#pragma mark - Private Methods
- (void)loadUserStreamsForPage:(NSInteger)pageNumber {

    [_loadingView startAnimating];
    
    [[TwitchAPIClient sharedClient] getUserFollowedStreamsWithPageNumber:_currentPage withCompletion:^(NSArray *result, BOOL pagesRemaining) {
        NSLog(@"UserViewController, loadUserStreamsForPage: %@, pagesRemaining?: %d",
              result, pagesRemaining);
        
        [self.userStreams addObjectsFromArray:result];
        _userStreamsLoaded = YES;
        _pagesRemainingToLoad = pagesRemaining;
        
        [self.collectionView reloadData];
        
        [_loadingView stopAnimating];
    }];
}

@end
