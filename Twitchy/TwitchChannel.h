//
//  TwitchChannel.h
//  Twitchy
//
//  Created by James Eunson on 4/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface TwitchChannel : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong, readonly) NSNumber * channelId;

@property (nonatomic, strong, readonly) NSURL * background;
@property (nonatomic, strong, readonly) NSURL * banner;
@property (nonatomic, strong, readonly) NSString * broadcasterLanguage;
@property (nonatomic, strong, readonly) NSDate * createdAt;
@property (nonatomic, strong, readonly) NSNumber * delay;
@property (nonatomic, strong, readonly) NSString * displayName;
@property (nonatomic, strong, readonly) NSNumber * followers;
@property (nonatomic, strong, readonly) NSString * game;
@property (nonatomic, strong, readonly) NSString * language;
@property (nonatomic, strong, readonly) NSURL * logo;
@property (nonatomic, strong, readonly) NSNumber * mature;
@property (nonatomic, strong, readonly) NSString * name;
@property (nonatomic, strong, readonly) NSNumber * partner;
@property (nonatomic, strong, readonly) NSURL * profileBanner;
@property (nonatomic, strong, readonly) NSURL * profileBannerBackgroundColor;
@property (nonatomic, strong, readonly) NSString * status;
@property (nonatomic, strong, readonly) NSDate * updatedAt;
@property (nonatomic, strong, readonly) NSURL * url;
@property (nonatomic, strong, readonly) NSURL * videoBanner;
@property (nonatomic, strong, readonly) NSNumber * views;

@end
