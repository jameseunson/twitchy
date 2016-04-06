//
//  LoadingViewHelper.m
//  Twitchy
//
//  Created by James Eunson on 6/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "LoadingViewHelper.h"

#define kLoadingViewHelperActivityIndicatorTag 2444
#define kLoadingViewHelperVisualEffectsViewTag 2445

@implementation LoadingViewHelper

+ (void)addLoadingViewToContainerView:(UIView*)view  {
    
    __block UIVisualEffectView * blurEffectView = [[UIVisualEffectView alloc] initWithEffect:
                                                   [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    blurEffectView.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    blurEffectView.alpha = 0;
    blurEffectView.tag = kLoadingViewHelperVisualEffectsViewTag;
    [view addSubview:blurEffectView];
    
    __block UIActivityIndicatorView * loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                                                     UIActivityIndicatorViewStyleWhiteLarge];
    
    loadingView.color = [UIColor darkGrayColor];
    loadingView.center = view.center;
    loadingView.tag = kLoadingViewHelperActivityIndicatorTag;
    [view addSubview:loadingView];
    
    // This causes a warning, but appears to work fine?
    // None of the suggested alternatives online work
    [UIView animateWithDuration:0.3 animations:^{
        blurEffectView.alpha = 1;
    }];
    [loadingView startAnimating];
}

+ (void)removeLoadingViewToContainerView:(UIView*)view {
    
    UIVisualEffectView * blurEffectView = [[[view subviews] filteredArrayUsingPredicate:
                                            [NSPredicate predicateWithFormat:@"tag == %d",
                                             kLoadingViewHelperVisualEffectsViewTag]] firstObject];
    if(blurEffectView) {
        [blurEffectView removeFromSuperview];
    }
    
    UIActivityIndicatorView * loadingView = [[[view subviews] filteredArrayUsingPredicate:
                                            [NSPredicate predicateWithFormat:@"tag == %d",
                                             kLoadingViewHelperActivityIndicatorTag]] firstObject];
    if(loadingView) {
        [loadingView stopAnimating];
        [loadingView removeFromSuperview];
    }
}

@end
