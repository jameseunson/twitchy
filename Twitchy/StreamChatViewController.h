//
//  StreamChatViewController.h
//  Twitchy
//
//  Created by James Eunson on 6/05/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TwitchStream.h"

#import <GMIRCClient/GMIRCClient-umbrella.h>
#import "GMIRCClient-Swift.h"

@interface StreamChatViewController : UITableViewController <GMIRCClientDelegate>

@property (nonatomic, strong) GMSocket * socket;
@property (nonatomic, strong) GMIRCClient * client;

@property (nonatomic, strong) TwitchStream * stream;

@end
