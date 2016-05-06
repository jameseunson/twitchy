//
//  LabelHelper.m
//  SimpleHN-objc
//
//  Created by James Eunson on 9/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "LabelHelper.h"

#define kBaseFontSize 17.0f

@implementation LabelHelper

+ (UILabel*)labelWithFont:(UIFont*)font {
    return [[self class] labelWithFont:font color:[UIColor blackColor] alignment:NSTextAlignmentNatural];
}

+ (UILabel*)labelWithFont:(UIFont*)font color:(UIColor*)color {
    return [[self class] labelWithFont:font color:color alignment:NSTextAlignmentNatural];
}

+ (UILabel*)labelWithFont:(UIFont*)font color:(UIColor*)color alignment:(NSTextAlignment)alignment {
    
    UILabel * label = [[UILabel alloc] init];
    
    label.font = font;
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.textColor = [UIColor blackColor];
    
    label.textAlignment = alignment;
    label.textColor = color;
    
    return label;
}

+ (UIFont*)adjustedBodyFont {
    return [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

+ (UIFont*)adjustedItalicBodyFont {
    UIFontDescriptor * descriptor = [[self adjustedBodyFont].fontDescriptor
                                     fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic];
    UIFont * font = [UIFont fontWithDescriptor:descriptor size:0];
    return font;
}

+ (UIFont*)adjustedBoldBodyFont {
    UIFontDescriptor * descriptor = [[self adjustedBodyFont].fontDescriptor
                                     fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    UIFont * font = [UIFont fontWithDescriptor:descriptor size:0];
    return font;
}

+ (UIFont*)adjustedMonospacedBodyFont {
    UIFontDescriptor * descriptor = [[self adjustedBodyFont].fontDescriptor
                                     fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitMonoSpace];
    UIFont * font = [UIFont fontWithDescriptor:descriptor size:0];
    return font;
}

@end
