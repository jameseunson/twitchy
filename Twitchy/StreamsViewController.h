//
//  SecondViewController.h
//  Twitchy
//
//  Created by James Eunson on 1/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TwitchGame.h"

@interface StreamsViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) IBOutlet UICollectionView * collectionView;

@property (nonatomic, strong) TwitchGame * gameFilter;
@property (nonatomic, strong) NSArray * existingStreams;

@end

