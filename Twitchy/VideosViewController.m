//
//  VideosViewController.m
//  Twitchy
//
//  Created by James Eunson on 4/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "VideosViewController.h"
#import "SectionHeaderReusableView.h"
#import "GameStreamsLoadingMoreCollectionViewCell.h"
#import "TwitchAPIClient.h"
#import "VideoCollectionViewCell.h"

@interface VideosViewController ()

@property (nonatomic, strong) UIActivityIndicatorView * loadingView;
@property (nonatomic, strong) NSMutableArray * videos;

@property (nonatomic, assign) BOOL videosLoaded;
@property (nonatomic, assign) BOOL pagesRemainingToLoad;

@property (nonatomic, assign) NSInteger currentPage;

- (void)loadVideosForPage:(NSInteger)pageNumber;

@end

#define kVideoCellReuseIdentifier @"videoCellReuseIdentifier"
#define kGameStreamsViewMoreCellReuseIdentifier @"gameStreamsViewMoreCellReuseIdentifier"
#define kHeaderReuseIdentifier @"headerReuseIdentifier"

@implementation VideosViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        self.videos = [[NSMutableArray alloc] init];
        
        _videosLoaded = NO;
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
    
    [self loadVideosForPage:_currentPage];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if(_videosLoaded) {
        return [_videos count] + 1;
        
    } else {
        return 0;
    }
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == [_videos count] && _pagesRemainingToLoad) {
        GameStreamsLoadingMoreCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:
                                                           kGameStreamsViewMoreCellReuseIdentifier forIndexPath:indexPath];
        [cell.loadingView startAnimating];
        return cell;
        
    } else {
        VideoCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:
                                         kVideoCellReuseIdentifier forIndexPath:indexPath];
        
        cell.video = _videos[indexPath.row];
        return cell;
    }
}

- (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    SectionHeaderReusableView * view = (SectionHeaderReusableView*)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderReuseIdentifier forIndexPath:indexPath];
    
    view.titleLabel.text = @"All Videos";
    
    return view;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == [_videos count] && [_videos count] > 0 && _pagesRemainingToLoad) {
        
        if(_videosLoaded) {
            _videosLoaded = NO;
            self.currentPage++;
            
            [self loadVideosForPage:_currentPage];
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == [_videos count]) {
        
        if(_videosLoaded) {
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
    TwitchVideo * selectedVideo = self.videos[indexPath.row];
    [selectedVideo presentVideoInViewController:self];
}

#pragma mark - Private Methods
- (void)loadVideosForPage:(NSInteger)pageNumber {
    
    [_loadingView startAnimating];
    
    [[TwitchAPIClient sharedClient] loadTopVideosWithPageNumber:_currentPage withCompletion:^(NSArray *result, BOOL pagesRemaining) {
        [self.videos addObjectsFromArray:result];
        _videosLoaded = YES;
        _pagesRemainingToLoad = pagesRemaining;
        
        [self.collectionView reloadData];
        
        [_loadingView stopAnimating];
    }];
}

@end
