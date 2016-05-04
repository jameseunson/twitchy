//
//  AppConfig.m
//  Twitchy
//
//  Created by James Eunson on 4/05/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "AppConfig.h"

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

- (void)setUpConfig {

    _configDict = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:kConfigStoreName]];
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

- (id)objectForKey:(NSString*)key {
    return _configDict[key];
}

- (NSString*)oAuthUsername {
    return [self objectForKey:kOAuthUsername];
}

- (NSString*)oAuthToken {
    return [self objectForKey:kOAuthToken];
}

@end


