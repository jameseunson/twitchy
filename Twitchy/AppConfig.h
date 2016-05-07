//
//  AppConfig.h
//  Twitchy
//
//  Created by James Eunson on 4/05/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kConfigStoreName @"MonashConfig"

// Session
#define kOAuthUsername @"oAuthUsername"
#define kOAuthToken @"oAuthToken"

#define kStreamChatEmoticonsDownloadStarted @"streamChatEmoticonsDownloadStarted"
#define kStreamChatEmoticonsDownloadFinished @"streamChatEmoticonsDownloadFinished"

@interface AppConfig : NSObject

@property (nonatomic, strong) NSMutableDictionary * configDict;

- (void)saveConfig;
- (void)setUpConfig;
- (void)setDefaults;
- (void)resetConfig;

+ (AppConfig *)sharedConfig;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *oAuthUsername;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *oAuthToken;

@property (NS_NONATOMIC_IOSONLY, readonly, assign) BOOL streamChatEmoticonsDownloadStarted;
@property (NS_NONATOMIC_IOSONLY, readonly, assign) BOOL streamChatEmoticonsDownloadFinished;

- (void)setObject:(id)object forKey:(NSString*)key;
- (void)setBool:(BOOL)value forKey:(NSString *)key;

- (BOOL)boolForKey:(NSString*)key;
- (id)objectForKey:(NSString*)key;


@end
