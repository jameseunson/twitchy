//
//  TwitchIRCClient.h
//  Twitchy
//
//  Created by James Eunson on 7/05/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GMIRCClient/GMIRCClient-umbrella.h>
#import "GMIRCClient-Swift.h"
#import "TwitchAPIClient.h"

#define kIRCBaseURL @"irc.chat.twitch.tv"
#define kIRCPort 6667

#define kTwitchIRCClientReadyToJoinChannelNotification @"twitchIRCClientReadyToJoinChannelNotification"
#define kTwitchIRCClientReceivedMessageNotification @"twitchIRCClientReceivedMessageNotification"
#define kTwitchIRCClientDownloadedEmoticonImageNotification @"twitchIRCClientDownloadedEmoticonImageNotification"

@interface TwitchIRCClient : NSObject <GMIRCClientDelegate>
+ (TwitchIRCClient*)sharedClient;

@property (nonatomic, strong) GMSocket * socket;
@property (nonatomic, strong) GMIRCClient * client;

@property (nonatomic, strong) NSMutableArray * messages;

- (void)joinChannel:(NSString*)name;
- (void)leaveChannel:(NSString*)name;

@end
