//
//  StreamCollectionViewCell.h
//  Twitchy
//
//  Created by James Eunson on 4/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TwitchStream.h"

#define kStreamCollectionViewCellWidth 548.0f
#define kStreamCollectionViewCellHeight 400.0f

@interface StreamCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) TwitchStream * stream;

@property (nonatomic, strong) IBOutlet UIImageView * imageView;
@property (nonatomic, strong) IBOutlet UILabel * titleLabel;
@property (nonatomic, strong) IBOutlet UILabel * subtitleLabel;
@property (nonatomic, strong) IBOutlet UILabel * viewersLabel;

@end
