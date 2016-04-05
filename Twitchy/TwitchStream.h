//
//  TwitchStream.h
//  Twitchy
//
//  Created by James Eunson on 4/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "TwitchChannel.h"
#import "TwitchImage.h"

@import UIKit;
@import AVKit;

@interface TwitchStream : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong, readonly) TwitchChannel * channel;
@property (nonatomic, strong, readonly) TwitchImage * preview;

@property (nonatomic, strong, readonly) NSNumber * streamId;
@property (nonatomic, strong, readonly) NSNumber * averageFps;
@property (nonatomic, strong, readonly) NSDate * createdAt;
@property (nonatomic, strong, readonly) NSNumber * delay;
@property (nonatomic, strong, readonly) NSString * game;
@property (nonatomic, strong, readonly) NSNumber * isPlaylist;

@property (nonatomic, strong, readonly) NSNumber * viewers;
@property (nonatomic, strong, readonly) NSNumber * videoHeight;

- (void)presentStreamInViewController:(UIViewController*)controller;

@end
