//
//  StreamChatViewController.h
//  Twitchy
//
//  Created by James Eunson on 6/05/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TwitchStream.h"

@interface StreamChatViewController : UITableViewController

@property (nonatomic, strong) TwitchStream * stream;

@end
