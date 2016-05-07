//
//  AppConfig.m
//  Twitchy
//
//  Created by James Eunson on 4/05/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "AppConfig.h"

#define kConfigDefaultsDict @{ \
    kStreamChatEmoticonsDownloadStarted: @(NO),\
    kStreamChatEmoticonsDownloadFinished: @(NO),\
}\


@implementation AppConfig

+ (AppConfig *)sharedConfig
{
    static dispatch_once_t pred = 0;
    __strong static AppConfig *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (instancetype)init
{
    if (!(self = [super init]))
        return nil;
    
    [self setUpConfig];
    return self;
}

- (void)setDefaults {
    _configDict[kStreamChatEmoticonsDownloadStarted] = kConfigDefaultsDict[kStreamChatEmoticonsDownloadStarted];
    _configDict[kStreamChatEmoticonsDownloadFinished] = kConfigDefaultsDict[kStreamChatEmoticonsDownloadFinished];
}

- (void)setUpConfig {

    _configDict = [[NSMutableDictionary alloc] initWithDictionary:
                   [[NSUserDefaults standardUserDefaults] dictionaryForKey:kConfigStoreName]];
    
    if([[_configDict allKeys] count] == 0) {
        [self setDefaults];
    }
    [self saveConfig];
}

- (void)saveConfig {
    
    [[NSUserDefaults standardUserDefaults] setObject:_configDict forKey:kConfigStoreName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)resetConfig {
    
    _configDict = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kConfigStoreName];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self setUpConfig];
}

- (void)setObject:(id)object forKey:(NSString*)key {
    _configDict[key] = object;
    [self saveConfig];
}
- (void)setBool:(BOOL)value forKey:(NSString *)key {
    _configDict[key] = @(value);
    [self saveConfig];
}

- (BOOL)boolForKey:(NSString*)key {
    return [_configDict[key] boolValue];
}
- (id)objectForKey:(NSString*)key {
    return _configDict[key];
}

- (NSString*)oAuthUsername {
    return [self objectForKey:kOAuthUsername];
}

- (NSString*)oAuthToken {
    return [self objectForKey:kOAuthToken];
}

- (BOOL)streamChatEmoticonsDownloadStarted {
    if(![[_configDict allKeys] containsObject:kStreamChatEmoticonsDownloadStarted]) {
        _configDict[kStreamChatEmoticonsDownloadStarted] = kConfigDefaultsDict[kStreamChatEmoticonsDownloadStarted];
    }
    return [_configDict[kStreamChatEmoticonsDownloadStarted] boolValue];
}

- (BOOL)streamChatEmoticonsDownloadFinished {
    if(![[_configDict allKeys] containsObject:kStreamChatEmoticonsDownloadFinished]) {
        _configDict[kStreamChatEmoticonsDownloadFinished] = kConfigDefaultsDict[kStreamChatEmoticonsDownloadFinished];
    }
    return [_configDict[kStreamChatEmoticonsDownloadFinished] boolValue];
}

@end


