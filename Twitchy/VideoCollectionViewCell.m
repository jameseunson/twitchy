//
//  VideoCollectionViewCell.m
//  Twitchy
//
//  Created by James Eunson on 6/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "VideoCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"

@implementation VideoCollectionViewCell

- (void)setVideo:(TwitchVideo *)video {
    _video = video;
    
    self.titleLabel.text = video.title;
    self.subtitleLabel.text = [NSString stringWithFormat:@"%@ views on %@",
                               [video.views stringValue], video.channel.displayName];
    
    //    [self.imageView setImageWithURL:stream.preview.large];
    
    TwitchVideoThumbnail * thumb = [video.thumbnails firstObject];
    NSURLRequest * request = [NSURLRequest requestWithURL:thumb.url];
    
    __block VideoCollectionViewCell * blockSelf = self;
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
