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

@import AVKit;

#define kStreamCellReuseIdentifier @"streamCellReuseIdentifier"
#define kGameStreamsViewMoreCellReuseIdentifier @"gameStreamsViewMoreCellReuseIdentifier"
#define kHeaderReuseIdentifier @"headerReuseIdentifier"

@interface StreamsViewController ()

@property (nonatomic, strong) UIActivityIndicatorView * loadingView;
@property (nonatomic, strong) NSMutableArray * streams;
@property (nonatomic, assign) BOOL streamsLoaded;

@property (nonatomic, assign) NSInteger currentPage;

- (void)loadStreamsForPage:(NSInteger)pageNumber;

@end

@implementation StreamsViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        self.streams = [[NSMutableArray alloc] init];
        
        _streamsLoaded = NO;
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

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_streams count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    StreamCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:
                                       kStreamCellReuseIdentifier forIndexPath:indexPath];
    
    cell.stream = _streams[indexPath.row];
    return cell;
}

- (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    SectionHeaderReusableView * view = (SectionHeaderReusableView*)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderReuseIdentifier forIndexPath:indexPath];
    
    view.titleLabel.text = @"All Channels";
    
    return view;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(kStreamCollectionViewCellWidth, kStreamCollectionViewCellHeight);
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    TwitchStream * selectedStream = self.streams[indexPath.row];
    [selectedStream presentStreamInViewController:self];
}

#pragma mark - Private Methods
- (void)loadStreamsForPage:(NSInteger)pageNumber {
    
    [_loadingView startAnimating];
    
    if(_existingStreams) {
        
        [self.streams addObjectsFromArray:_existingStreams];
        [self.collectionView reloadData];
        
        [_loadingView stopAnimating];
        
    } else {
        [[TwitchAPIClient sharedClient] loadTopStreamsWithGameFilter:_gameFilter withCompletion:^(NSArray *result) {
            [self.streams addObjectsFromArray:result];
            [self.collectionView reloadData];
            
            [_loadingView stopAnimating];
        }];
    }
}

@end
