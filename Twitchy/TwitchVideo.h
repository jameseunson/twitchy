//
//  TwitchVideo.h
//  Twitchy
//
//  Created by James Eunson on 6/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "TwitchVideoChannel.h"

#import "TwitchVideoFps.h"
#import "TwitchVideoResolutions.h"
#import "TwitchVideoThumbnail.h"

@import UIKit;

@interface TwitchVideo : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong, readonly) TwitchVideoChannel * channel;
@property (nonatomic, strong, readonly) TwitchVideoFps * fps;
@property (nonatomic, strong, readonly) TwitchVideoResolutions * resolutions;
@property (nonatomic, strong, readonly) NSArray < TwitchVideoThumbnail * > * thumbnails;

@property (nonatomic, strong, readonly) NSString * videoId;
@property (nonatomic, strong, readonly) NSNumber * broadcastId;
@property (nonatomic, strong, readonly) NSString * broadcastType;

@property (nonatomic, strong, readonly) NSDate * createdAt;
@property (nonatomic, strong, readonly) NSString * videoDescription;

@property (nonatomic, strong, readonly) NSString * game;
@property (nonatomic, strong, readonly) NSNumber * length;
@property (nonatomic, strong, readonly) NSURL * preview;

@property (nonatomic, strong, readonly) NSDate * recordedAt;

@property (nonatomic, strong, readonly) NSString * status;
@property (nonatomic, strong, readonly) NSString * tagList;

@property (nonatomic, strong, readonly) NSString * title;
@property (nonatomic, strong, readonly) NSURL * url;
@property (nonatomic, strong, readonly) NSNumber * views;

- (void)presentVideoInViewController:(UIViewController*)controller;

@end
