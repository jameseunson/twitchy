//
//  LoadingViewHelper.h
//  Twitchy
//
//  Created by James Eunson on 6/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import <Foundation/Foundation.h>

@import UIKit;

@interface LoadingViewHelper : NSObject

+ (void)addLoadingViewToContainerView:(UIView*)view;
+ (void)removeLoadingViewToContainerView:(UIView*)view;

@end
