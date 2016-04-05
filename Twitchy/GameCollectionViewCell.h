//
//  GameCollectionViewCell.h
//  Twitchy
//
//  Created by James Eunson on 4/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TwitchGameListing.h"

#define kGameCollectionViewCellWidth 272.0f
#define kGameCollectionViewCellHeight 470.0f

@interface GameCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView * imageView;
@property (nonatomic, strong) IBOutlet UILabel * titleLabel;
@property (nonatomic, strong) IBOutlet UILabel * subtitleLabel;

@property (nonatomic, strong) TwitchGameListing * gameListing;

@end
