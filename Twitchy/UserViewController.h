//
//  UserViewController.h
//  Twitchy
//
//  Created by James Eunson on 6/05/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) IBOutlet UICollectionView * collectionView;

@property (nonatomic, strong) NSArray * existingStreams;

@end
