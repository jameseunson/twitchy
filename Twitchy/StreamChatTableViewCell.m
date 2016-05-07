//
//  StreamChatTableViewCell.m
//  Twitchy
//
//  Created by James Eunson on 6/05/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "StreamChatTableViewCell.h"
#import "LabelHelper.h"

static NSMutableDictionary * _usernameColorLookup = nil;

@interface StreamChatTableViewCell ()

+ (NSMutableDictionary*)usernameColorLookup;

@end

@implementation StreamChatTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        
        self.fromLabel = [LabelHelper labelWithFont:[LabelHelper adjustedBodyFont]
                                              color:[UIColor whiteColor] alignment:NSTextAlignmentRight];
        [self.contentView addSubview:_fromLabel];
        
        self.messageLabel = [LabelHelper labelWithFont:[LabelHelper adjustedBodyFont]
                                                 color:[UIColor whiteColor]];
        [self.contentView addSubview:_messageLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat fromLabelWidth = roundf((self.contentView.frame.size.width - 20.0f) / 3);
    CGFloat messageLabelWidth = roundf((self.contentView.frame.size.width - 20.0f) / 3) * 2;
    
    CGRect boundingRectForFromLabel = CGRectIntegral( [_fromLabel.text boundingRectWithSize:CGSizeMake(fromLabelWidth, CGFLOAT_MAX) options:NSLineBreakByWordWrapping|NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName: [LabelHelper adjustedBodyFont] } context:nil] );
    self.fromLabel.frame = CGRectMake(0, 0, boundingRectForFromLabel.size.width, boundingRectForFromLabel.size.height);
    
    CGRect boundingRectForMessageLabel = CGRectZero;
    if(_messageLabel.attributedText) {
        boundingRectForMessageLabel = [_messageLabel.attributedText boundingRectWithSize:CGSizeMake(messageLabelWidth, CGFLOAT_MAX) options:NSLineBreakByWordWrapping|NSStringDrawingUsesLineFragmentOrigin context:nil];
        
    } else {
        boundingRectForMessageLabel = CGRectIntegral( [_messageLabel.text boundingRectWithSize:CGSizeMake(messageLabelWidth, CGFLOAT_MAX) options:NSLineBreakByWordWrapping|NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName: [LabelHelper adjustedBodyFont] } context:nil] );
    }
    self.messageLabel.frame = CGRectMake(fromLabelWidth + 20.0f, 0, boundingRectForMessageLabel.size.width, boundingRectForMessageLabel.size.height);
}

+ (CGFloat)heightWithMessage:(NSDictionary*)message withWidth:(CGFloat)width {
    
    CGFloat fromLabelWidth = roundf((width - 20.0f) / 3);
    CGFloat messageLabelWidth = roundf((width - 20.0f) / 3) * 2;
    
    CGRect boundingRectForFromLabel = CGRectIntegral( [message[@"from"] boundingRectWithSize:CGSizeMake(fromLabelWidth, CGFLOAT_MAX) options:NSLineBreakByWordWrapping|NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName: [LabelHelper adjustedBodyFont] } context:nil] );
    
    CGRect boundingRectForMessageLabel = CGRectZero;
    if([message[@"text"] isKindOfClass:[NSAttributedString class]]) {
        NSAttributedString * attributedText = message[@"text"];
        boundingRectForMessageLabel = [attributedText boundingRectWithSize:CGSizeMake(messageLabelWidth, CGFLOAT_MAX) options:NSLineBreakByWordWrapping|NSStringDrawingUsesLineFragmentOrigin context:nil];
        
    } else {
        NSString * text = message[@"text"];
        boundingRectForMessageLabel = CGRectIntegral( [text boundingRectWithSize:CGSizeMake(messageLabelWidth, CGFLOAT_MAX) options:NSLineBreakByWordWrapping|NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName: [LabelHelper adjustedBodyFont] } context:nil] );
    }
    
    CGFloat maxHeight = MAX(roundf(boundingRectForFromLabel.size.height), roundf(boundingRectForMessageLabel.size.height));
    return maxHeight + 20.0f;
}

#pragma mark - Property Override Methods
- (void)setMessage:(NSDictionary *)message {
    _message = message;
    
    self.fromLabel.text = message[@"from"];
    
    NSMutableDictionary * usernameColorLookup = [[self class] usernameColorLookup];
    UIColor * fromColor = nil;
    
    if([[usernameColorLookup allKeys] containsObject:message[@"from"]]) {
        fromColor = usernameColorLookup[message[@"from"]];
        
    } else {
        fromColor = [UIColor colorWithHue:( arc4random() % 256 / 256.0 )
                               saturation:1 brightness:1 alpha:1];
        usernameColorLookup[message[@"from"]] = fromColor;
    }
    if(fromColor) {
        self.fromLabel.textColor = fromColor;
    }
    
    if([message[@"text"] isKindOfClass:[NSAttributedString class]]) {
        self.messageLabel.attributedText = message[@"text"];
        
    } else {
        self.messageLabel.text = message[@"text"];
    }
    
    [self setNeedsLayout];
}

#pragma mark - Static Methods
+ (NSMutableDictionary*)usernameColorLookup {
    if(!_usernameColorLookup) {
        _usernameColorLookup = [[NSMutableDictionary alloc] init];
    }
    return _usernameColorLookup;
}

@end
