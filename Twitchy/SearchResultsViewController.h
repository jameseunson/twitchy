//
//  SearchResultsViewController.h
//  Twitchy
//
//  Created by James Eunson on 6/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchViewController.h"

@protocol SearchViewControllerResultsDelegate;
@interface SearchResultsViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout, SearchViewControllerResultsDelegate>

@property (nonatomic, strong) NSMutableArray * games;
@property (nonatomic, strong) NSMutableArray * streams;

@property (nonatomic, assign, getter=isLoading) BOOL loading;

@property (nonatomic, strong) IBOutlet UICollectionView * collectionView;

@end
