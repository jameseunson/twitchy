//
//  GameCollectionViewCell.m
//  Twitchy
//
//  Created by James Eunson on 4/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "GameCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"

@implementation GameCollectionViewCell

#pragma mark - Property Override Methods
- (void)setGameListing:(TwitchGameListing *)gameListing {
    _gameListing = gameListing;
    
    self.titleLabel.text = gameListing.game.name;
    self.subtitleLabel.text = [NSString stringWithFormat:@"%@ viewers",
                               [gameListing.viewers stringValue]];
    
    NSURLRequest * request = [NSURLRequest requestWithURL:gameListing.game.box.large];
    
    __block GameCollectionViewCell * blockSelf = self;
    [self.imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        
        // Came from network
        if(response) {
            blockSelf.imageView.alpha = 0;
            blockSelf.imageView.image = image;
            
            [UIView animateWithDuration:0.3 animations:^{
                blockSelf.imageView.alpha = 1.0f;
            }];
        } else { // Came from cache
            blockSelf.imageView.image = image;
        }
        
    } failure:nil];
}

- (void)prepareForReuse {
    self.imageView.image = nil;
    [self setNeedsDisplay];
}

@end
