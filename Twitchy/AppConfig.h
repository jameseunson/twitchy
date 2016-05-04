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

@interface AppConfig : NSObject

@property (nonatomic, strong) NSMutableDictionary * configDict;

- (void)saveConfig;
- (void)setUpConfig;
- (void)resetConfig;

+ (AppConfig *)sharedConfig;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *oAuthUsername;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *oAuthToken;

- (void)setObject:(id)object forKey:(NSString*)key;
- (id)objectForKey:(NSString*)key;

@end
