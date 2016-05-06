//
//  LabelHelper.h
//  SimpleHN-objc
//
//  Created by James Eunson on 9/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LabelHelper : NSObject

+ (UILabel*)labelWithFont:(UIFont*)font;
+ (UILabel*)labelWithFont:(UIFont*)font color:(UIColor*)color;
+ (UILabel*)labelWithFont:(UIFont*)font color:(UIColor*)color alignment:(NSTextAlignment)alignment;

// Dynamic type body font adjusted from the
// default 17pt to 16pt, which looks slightly less
// over-large
+ (UIFont*)adjustedBodyFont;
+ (UIFont*)adjustedItalicBodyFont;
+ (UIFont*)adjustedBoldBodyFont;
+ (UIFont*)adjustedMonospacedBodyFont;

@end
