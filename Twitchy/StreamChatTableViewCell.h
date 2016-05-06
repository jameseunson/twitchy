//
//  StreamChatTableViewCell.h
//  Twitchy
//
//  Created by James Eunson on 6/05/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StreamChatTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel * fromLabel;
@property (nonatomic, strong) UILabel * messageLabel;

@property (nonatomic, strong) NSDictionary * message;

+ (CGFloat)heightWithMessage:(NSDictionary*)message withWidth:(CGFloat)width;

@end
