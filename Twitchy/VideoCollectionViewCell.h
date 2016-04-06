//
//  VideoCollectionViewCell.h
//  Twitchy
//
//  Created by James Eunson on 6/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "StreamCollectionViewCell.h"
#import "TwitchVideo.h"

@interface VideoCollectionViewCell : StreamCollectionViewCell

@property (nonatomic, strong) TwitchVideo * video;

@end
