//
//  TwitchAPIClient.m
//  Twitchy
//
//  Created by James Eunson on 4/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "TwitchAPIClient.h"
#import "AFHTTPSessionManager.h"

#import <Mantle/Mantle.h>

static TwitchAPIClient * _sharedClient = nil;

@interface TwitchAPIClient ()

@property (nonatomic, strong, readonly) AFHTTPSessionManager * clientManager;
@property (nonatomic, strong, readonly) AFHTTPSessionManager * accessTokenManager;
@property (nonatomic, strong, readonly) AFHTTPSessionManager * usherManager;

@property (nonatomic, strong) NSMutableDictionary * accessTokenLookup;

+ (NSArray*)_processResponseObject:(NSArray *)streams class:(Class)class;
- (NSDictionary*)_getCachedAuthorizationTokenForKey:(NSString*)key;

@end

@implementation TwitchAPIClient
@synthesize clientManager = _clientManager;
@synthesize accessTokenManager = _accessTokenManager;
@synthesize usherManager = _usherManager;

+ (TwitchAPIClient*)sharedClient {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[TwitchAPIClient alloc] init];
    });
    return _sharedClient;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        self.accessTokenLookup = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - Games
- (void)loadTopGamesWithPageNumber:(NSInteger)pageNumber withCompletion: (void (^)(NSArray * result))completion {
    
    NSString * urlString = [NSString stringWithFormat:@"games/top?limit=25&offset=%@", @(pageNumber * 25)];
    
    [self.clientManager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary * responseDict = (NSDictionary *)responseObject;
        if(![responseObject isKindOfClass:[NSDictionary class]]
           || ![[responseDict allKeys] containsObject:@"top"]) {
            completion(nil);
            return;
        }
        
        completion([[self class] _processResponseObject:responseDict[@"top"] class:TwitchGameListing.class]);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"loadTopGamesWithCompletion, failure, %@", error);
    }];
}

- (void)loadTopGamesWithCompletion: (void (^)(NSArray * result))completion {
    [self loadTopGamesWithPageNumber:0 withCompletion:completion];
}

- (void)loadTopStreamsWithCompletion: (void (^)(NSArray * result))completion {
    [self loadTopStreamsWithGameFilter:nil withPageNumber:0 withCompletion:completion];
}

- (void)loadTopStreamsWithGameFilter:(TwitchGame*)game withCompletion: (void (^)(NSArray * result))completion {
    [self loadTopStreamsWithGameFilter:game withPageNumber:0 withCompletion:completion];
}

#pragma mark - Streams
- (void)loadTopStreamsWithGameFilter:(TwitchGame*)game withPageNumber:(NSInteger)pageNumber withCompletion: (void (^)(NSArray * result))completion {
    NSDictionary * params = nil;
    if(game) {
        params = @{ @"game": game.name };
    }
    
    NSString * urlString = [NSString stringWithFormat:@"streams?limit=25&offset=%@", @(pageNumber * 25)];
    
    [self.clientManager GET:urlString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary * responseDict = (NSDictionary *)responseObject;
        if(![responseObject isKindOfClass:[NSDictionary class]]
           || ![[responseDict allKeys] containsObject:@"streams"]) {
            completion(nil);
            return;
        }
        completion([[self class] _processResponseObject:responseDict[@"streams"] class:TwitchStream.class]);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"loadTopStreamsWithCompletion, failure, %@", error);
    }];
}

#pragma mark - Featured
- (void)loadFeaturedStreamsWithCompletion: (void (^)(NSArray * result))completion {
    
    [self.clientManager GET:@"streams/featured" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary * responseDict = (NSDictionary *)responseObject;
        if(![responseObject isKindOfClass:[NSDictionary class]]
           || ![[responseDict allKeys] containsObject:@"featured"]) {
            completion(nil);
            return;
        }
        completion([[self class] _processResponseObject:responseDict[@"featured"] class:TwitchFeaturedStreamListing.class]);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"loadTopStreamsWithCompletion, failure, %@", error);
    }];
}

#pragma mark - Videos
- (void)loadTopVideosWithCompletion: (void (^)(NSArray * result))completion {
    [self loadTopVideosWithPageNumber:0 withCompletion:completion];
}

- (void)loadTopVideosWithPageNumber:(NSInteger)pageNumber withCompletion: (void (^)(NSArray * result))completion {
    
    NSString * urlString = [NSString stringWithFormat:@"videos/top?limit=25&offset=%@", @(pageNumber * 25)];
    
    [self.clientManager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary * responseDict = (NSDictionary *)responseObject;
        if(![responseObject isKindOfClass:[NSDictionary class]]
           || ![[responseDict allKeys] containsObject:@"videos"]) {
            completion(nil);
            return;
        }
        completion([[self class] _processResponseObject:responseDict[@"videos"] class:TwitchVideo.class]);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"loadTopVideosWithPageNumber, failure, %@", error);
    }];
}

#pragma mark - Authentication
- (void)loadAccessTokenForVideo:(TwitchVideo*)video withCompletion: (void (^)(NSDictionary * result))completion {
    
    // /api/vods/1234567/access_token - remove v from v1234567
    NSString * videoId = [video.videoId substringFromIndex:1];
    NSString * urlStringForVideo = [NSString stringWithFormat:@"api/vods/%@/access_token",
                                      [video.videoId substringFromIndex:1]];
 
    NSDictionary * cachedToken = [self _getCachedAuthorizationTokenForKey:videoId];
    if(cachedToken) {
        completion(cachedToken);
        return;
    }
    
    [self.accessTokenManager GET:urlStringForVideo parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        _accessTokenLookup[videoId] = responseObject;
        completion(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"ERROR: %@", error);
    }];
}

- (void)loadAccessTokenForChannel:(TwitchChannel*)channel withCompletion: (void (^)(NSDictionary * result))completion {
    
    // /api/channels/c9sneaky/access_token
    NSString * urlStringForChannel = [NSString stringWithFormat:@"api/channels/%@/access_token", channel.name];
    
    NSDictionary * cachedToken = [self _getCachedAuthorizationTokenForKey:channel.name];
    if(cachedToken) {
        completion(cachedToken);
        return;
    }
    
    [self.accessTokenManager GET:urlStringForChannel parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        _accessTokenLookup[channel.name] = responseObject;
        completion(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"ERROR: %@", error);
    }];
}

#pragma mark - Helper methods
// Called sequentially after loadAccessTokenForChannel, providing the result of that method call
// as the 'token' parameter in this function call
+ (NSURL*)generateStreamingURLForChannel:(TwitchChannel*)channel withToken:(NSDictionary*)token {
    
    NSDictionary * params = @{ @"allow_source": @"true", @"allow_audio_only": @"true", @"allow_spectre": @"true", @"token": token[@"token"], @"sig": token[@"sig"] };
    NSString * paramsString = AFQueryStringFromParameters(params);
    
    NSString * urlStringForStreamURLRequest = [NSString stringWithFormat:@"%@/api/channel/hls/%@.m3u8?%@",
                                               kAPIUsherBaseURL, channel.name, paramsString];
    
    return [NSURL URLWithString:urlStringForStreamURLRequest];
}

+ (NSURL*)generateVideoURLForVideo:(TwitchVideo*)video withToken:(NSDictionary*)token {
    
    NSDictionary * params = @{ @"allow_source": @"true", @"allow_audio_only": @"true", @"nauth": token[@"token"], @"nauthsig": token[@"sig"] };
    NSString * paramsString = AFQueryStringFromParameters(params);
    
    NSString * videoId = [video.videoId substringFromIndex:1];
    NSString * urlStringForVideoURLRequest = [NSString stringWithFormat:@"%@/vod/%@.m3u8?%@",
                                               kAPIUsherBaseURL, videoId, paramsString];
    
    return [NSURL URLWithString:urlStringForVideoURLRequest];
}

#pragma mark - Search
- (void)searchGamesWithQuery:(NSString*)query withCompletion:(void (^)(NSArray * result))completion {
    
    NSDictionary * params = @{ @"query": query, @"type": @"suggest" };
    NSString * paramsString = AFQueryStringFromParameters(params);
    
    NSString * urlString = [NSString stringWithFormat:@"search/games?%@", paramsString];
    
    [self.clientManager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary * responseDict = (NSDictionary *)responseObject;
        
        if(![responseObject isKindOfClass:[NSDictionary class]]
           || ![[responseDict allKeys] containsObject:@"games"]) {
            completion(nil);
            return;
        }
        completion([[self class] _processResponseObject:responseDict[@"games"] class:TwitchGame.class]);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"searchGamesWithQuery, failure, %@", error);
    }];
}
- (void)searchStreamsWithQuery:(NSString*)query withCompletion:(void (^)(NSArray * result))completion {
    
    NSDictionary * params = @{ @"query": query };
    NSString * paramsString = AFQueryStringFromParameters(params);
    
    NSString * urlString = [NSString stringWithFormat:@"search/streams?%@", paramsString];
    
    [self.clientManager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary * responseDict = (NSDictionary *)responseObject;
        NSLog(@"searchStreamsWithQuery: %@", responseDict);
        
        if(![responseObject isKindOfClass:[NSDictionary class]]
           || ![[responseDict allKeys] containsObject:@"streams"]) {
            completion(nil);
            return;
        }
        completion([[self class] _processResponseObject:responseDict[@"streams"] class:TwitchStream.class]);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"searchStreamsWithQuery, failure, %@", error);
    }];
}

#pragma mark - Property Override Methods
- (AFHTTPSessionManager*)clientManager {
    
    if(_clientManager) {
        return _clientManager;
    }
    
    _clientManager = [[AFHTTPSessionManager alloc] initWithBaseURL:
                      [NSURL URLWithString:kAPIBaseURL]
                                              sessionConfiguration:
                      [NSURLSessionConfiguration defaultSessionConfiguration]];
    
    AFJSONRequestSerializer * requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setValue:kAPIClientID forHTTPHeaderField:@"Client-ID"];
    
    NSString * mimeTypeString = @"application/vnd.twitchtv.v3+json";
    [requestSerializer setValue:mimeTypeString forHTTPHeaderField:@"Accept"];
    [requestSerializer setValue:mimeTypeString forHTTPHeaderField:@"Content-Type"];
    
    _clientManager.requestSerializer = requestSerializer;
    
    return _clientManager;
}

- (AFHTTPSessionManager*)accessTokenManager {
    
    if(_accessTokenManager) {
        return _accessTokenManager;
    }
    _accessTokenManager = [[AFHTTPSessionManager alloc] initWithBaseURL:
                      [NSURL URLWithString:kAPIAccessTokenBaseURL]
                                              sessionConfiguration:
                      [NSURLSessionConfiguration defaultSessionConfiguration]];
    return _accessTokenManager;
}

#pragma mark - Private Methods
+ (NSArray*)_processResponseObject:(NSArray *)inputItems class:(Class)class {
    
    NSMutableArray * outputObjects = [[NSMutableArray alloc] init];
    for(NSDictionary * itemDict in inputItems) {
        
        NSError * error = nil;
        
        id item = [MTLJSONAdapter modelOfClass:class
                         fromJSONDictionary:itemDict error:&error];
    
        if(item && !error) {
            [outputObjects addObject:item];
            
        } else {
            if(error) {
                NSLog(@"ERROR, _processResponseObject: %@", error);
            } else {
                NSLog(@"ERROR, _processResponseObject: Unknown error");
            }
        }
    }
    return outputObjects;
}

- (NSDictionary*)_getCachedAuthorizationTokenForKey:(NSString *)key {
    
    if([[_accessTokenLookup allKeys] containsObject:key]) {
        
        NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
        NSDictionary * cachedTokenResponse = _accessTokenLookup[key];
        
        if([[cachedTokenResponse allKeys] containsObject:@"token"]) {
            
            NSError * error = nil;
            NSDictionary * tokenDict = [NSJSONSerialization JSONObjectWithData:[cachedTokenResponse[@"token"]
                                                                                dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
            if(tokenDict && !error && [[tokenDict allKeys] containsObject:@"expires"]) {
                
                NSTimeInterval cachedTokenResponseExpiry = [tokenDict[@"expires"] doubleValue];
                if(currentTime > cachedTokenResponseExpiry) {
                    
                    // Cached token has expired, remove from cache and retrieve new token from the network
                    NSLog(@"token has expired!");
                    [_accessTokenLookup removeObjectForKey:key];
                    
                } else {
                    
                    // Cached token is valid, return without hitting the network
                    return cachedTokenResponse;
                }
            }
        }
    }
    
    // Fallthrough, no cache found or cache was expired
    return nil;
}

@end
