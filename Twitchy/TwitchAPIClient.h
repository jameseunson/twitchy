//
//  TwitchAPIClient.h
//  Twitchy
//
//  Created by James Eunson on 4/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TwitchStream.h"
#import "TwitchGame.h"

#define kAPIBaseURL @"https://api.twitch.tv/kraken"
#define kAPIAccessTokenBaseURL @"https://api.twitch.tv"
#define kAPIUsherBaseURL @"http://usher.twitch.tv"

#define kAPIClientID @"brt3awieemfagtg57wtmdmvuuc3qwyl"
#define kAPIClientSecret @"a7ol5d3dqv6w2jpawexhig22ewi1ww"

@interface TwitchAPIClient : NSObject

+ (TwitchAPIClient*)sharedClient;

- (void)loadTopGamesWithPageNumber:(NSInteger)pageNumber withCompletion: (void (^)(NSArray * result))completion;
- (void)loadTopGamesWithCompletion: (void (^)(NSArray * result))completion;

- (void)loadTopVideosWithCompletion: (void (^)(NSArray * result))completion;

- (void)loadTopStreamsWithCompletion: (void (^)(NSArray * result))completion;
- (void)loadTopStreamsWithGameFilter:(TwitchGame*)game withCompletion: (void (^)(NSArray * result))completion;

- (void)loadFeaturedStreamsWithCompletion: (void (^)(NSArray * result))completion;

- (void)loadAccessTokenForChannel:(TwitchChannel*)channel withCompletion: (void (^)(NSDictionary * result))completion;

+ (NSURL*)generateStreamingURLForChannel:(TwitchChannel*)channel withToken:(NSDictionary*)token;

@end
