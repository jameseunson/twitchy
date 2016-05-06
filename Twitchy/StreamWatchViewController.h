//
//  StreamWatchViewController.h
//  Twitchy
//
//  Created by James Eunson on 4/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TwitchStream.h"
#import "StreamChatViewController.h"

@interface StreamWatchViewController : UISplitViewController

@property (nonatomic, strong) TwitchStream * stream;
@property (nonatomic, strong) StreamChatViewController * chatController;

@end
