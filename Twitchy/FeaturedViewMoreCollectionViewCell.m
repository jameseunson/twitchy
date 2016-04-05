//
//  FeaturedViewMoreCollectionViewCell.m
//  Twitchy
//
//  Created by James Eunson on 5/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "FeaturedViewMoreCollectionViewCell.h"

@interface FeaturedViewMoreCollectionViewCell ()

@end

@implementation FeaturedViewMoreCollectionViewCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        self.highlightViewMoreView.layer.cornerRadius = 8.0f;
        self.highlightViewMoreView.alpha = 0.4f;
    }
    return self;
}

- (void)didUpdateFocusInContext:(UIFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator
{
    if (self.focused)
    {
        // Apply focused appearence,
        // e.g scale both of them using transform or apply background color
        
        [coordinator addCoordinatedAnimations:^{
            self.highlightViewMoreView.transform = CGAffineTransformMakeScale(1.03, 1.1);
            self.highlightViewMoreView.alpha = 0.8f;
            
            self.highlightViewMoreView.layer.shadowOffset = CGSizeMake(0, 10.0f);
            self.highlightViewMoreView.layer.shadowColor = [UIColor blackColor].CGColor;
            self.highlightViewMoreView.layer.shadowRadius = 20.0f;
            self.highlightViewMoreView.layer.shadowOpacity = 0.3f;
            
        } completion:nil];
    }
    else
    {
        // Apply normal appearance
        [coordinator addCoordinatedAnimations:^{
            self.highlightViewMoreView.transform = CGAffineTransformIdentity;
            self.highlightViewMoreView.alpha = 0.4f;
            
            self.highlightViewMoreView.layer.shadowOffset = CGSizeZero;
            self.highlightViewMoreView.layer.shadowColor = [UIColor clearColor].CGColor;
            self.highlightViewMoreView.layer.shadowRadius = 0;
            self.highlightViewMoreView.layer.shadowOpacity = 0;
            
        } completion:nil];
    }
}

@end
