//
//  StreamCollectionViewCell.m
//  Twitchy
//
//  Created by James Eunson on 4/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "StreamCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"

@implementation StreamCollectionViewCell

- (void)setStream:(TwitchStream *)stream {
    _stream = stream;
    
    self.titleLabel.text = stream.channel.status;
    self.subtitleLabel.text = [NSString stringWithFormat:@"%@ viewers on %@",
                               [stream.viewers stringValue], stream.channel.displayName];
    
//    [self.imageView setImageWithURL:stream.preview.large];
    
    NSURLRequest * request = [NSURLRequest requestWithURL:stream.preview.large];
    
    __block StreamCollectionViewCell * blockSelf = self;
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
