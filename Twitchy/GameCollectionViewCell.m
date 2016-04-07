//
//  GameCollectionViewCell.m
//  Twitchy
//
//  Created by James Eunson on 4/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "GameCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "TwitchGame.h"

@interface GameCollectionViewCell ()

- (void)updateInterfaceForGame:(TwitchGame*)game;

@end

@implementation GameCollectionViewCell

- (void)prepareForReuse {
    self.imageView.image = nil;
    [self setNeedsDisplay];
}

#pragma mark - Property Override Methods
- (void)setGameListing:(TwitchGameListing *)gameListing {
    _gameListing = gameListing;
    
    self.subtitleLabel.text = [NSString stringWithFormat:@"%@ viewers",
                               [gameListing.viewers stringValue]];
    [self updateInterfaceForGame:gameListing.game];
}

- (void)setGame:(TwitchGame *)game {
    _game = game;
    
    self.subtitleLabel.text = @"";
    [self updateInterfaceForGame:game];
}

#pragma mark - Private Methods
- (void)updateInterfaceForGame:(TwitchGame*)game {
    self.titleLabel.text = game.name;
    
    NSURLRequest * request = [NSURLRequest requestWithURL:game.box.large];
    
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

@end
