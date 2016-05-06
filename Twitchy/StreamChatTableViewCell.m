//
//  StreamChatTableViewCell.m
//  Twitchy
//
//  Created by James Eunson on 6/05/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "StreamChatTableViewCell.h"
#import "LabelHelper.h"

@implementation StreamChatTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        
        self.fromLabel = [LabelHelper labelWithFont:[LabelHelper adjustedBodyFont]
                                              color:[UIColor lightGrayColor] alignment:NSTextAlignmentRight];
        _fromLabel.backgroundColor = [UIColor redColor];
        
        [self.contentView addSubview:_fromLabel];
        
        self.messageLabel = [LabelHelper labelWithFont:[LabelHelper adjustedBodyFont]
                                                 color:[UIColor whiteColor]];
        _messageLabel.backgroundColor = [UIColor redColor];
        
        [self.contentView addSubview:_messageLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSLog(@"StreamChatTableViewCell, frame, %@, contentView.frame: %@",
          NSStringFromCGRect(self.frame), NSStringFromCGRect(self.contentView.frame));
    
    CGFloat fromLabelWidth = roundf((self.contentView.frame.size.width - 20.0f) / 3);
    CGFloat messageLabelWidth = roundf((self.contentView.frame.size.width - 20.0f) / 3) * 2;
    
    CGRect boundingRectForFromLabel = CGRectIntegral( [_fromLabel.text boundingRectWithSize:CGSizeMake(fromLabelWidth, CGFLOAT_MAX) options:NSLineBreakByWordWrapping|NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName: [LabelHelper adjustedBodyFont] } context:nil] );
    self.fromLabel.frame = CGRectMake(0, 0, boundingRectForFromLabel.size.width, boundingRectForFromLabel.size.height);
    
    CGRect boundingRectForMessageLabel = CGRectIntegral( [_messageLabel.text boundingRectWithSize:CGSizeMake(messageLabelWidth, CGFLOAT_MAX) options:NSLineBreakByWordWrapping|NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName: [LabelHelper adjustedBodyFont] } context:nil] );
    self.messageLabel.frame = CGRectMake(fromLabelWidth + 20.0f, 0, boundingRectForMessageLabel.size.width, boundingRectForMessageLabel.size.height);
}

+ (CGFloat)heightWithMessage:(NSDictionary*)message withWidth:(CGFloat)width {
    
    CGFloat fromLabelWidth = roundf((width - 20.0f) / 3);
    CGFloat messageLabelWidth = roundf((width - 20.0f) / 3) * 2;
    
    CGRect boundingRectForFromLabel = CGRectIntegral( [message[@"from"] boundingRectWithSize:CGSizeMake(fromLabelWidth, CGFLOAT_MAX) options:NSLineBreakByWordWrapping|NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName: [LabelHelper adjustedBodyFont] } context:nil] );
    CGRect boundingRectForMessageLabel = CGRectIntegral( [message[@"text"] boundingRectWithSize:CGSizeMake(messageLabelWidth, CGFLOAT_MAX) options:NSLineBreakByWordWrapping|NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName: [LabelHelper adjustedBodyFont] } context:nil] );
    
    CGFloat maxHeight = MAX(roundf(boundingRectForFromLabel.size.height), roundf(boundingRectForMessageLabel.size.height));
    return maxHeight + 20.0f;
}

#pragma mark - Property Override Methods
- (void)setMessage:(NSDictionary *)message {
    _message = message;
    
    self.fromLabel.text = message[@"from"];
    self.messageLabel.text = message[@"text"];
    
    [self setNeedsLayout];
}

@end
