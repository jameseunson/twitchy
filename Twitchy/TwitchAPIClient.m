//
//  TwitchAPIClient.m
//  Twitchy
//
//  Created by James Eunson on 4/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "TwitchAPIClient.h"
#import "AFHTTPSessionManager.h"
#import "TwitchGameListing.h"
#import "TwitchFeaturedStreamListing.h"

#import <Mantle/Mantle.h>

static TwitchAPIClient * _sharedClient = nil;

@interface TwitchAPIClient ()

@property (nonatomic, strong, readonly) AFHTTPSessionManager * clientManager;
@property (nonatomic, strong, readonly) AFHTTPSessionManager * accessTokenManager;
@property (nonatomic, strong, readonly) AFHTTPSessionManager * usherManager;

@property (nonatomic, strong) NSMutableDictionary * accessTokenLookup;

+ (NSArray*)_processStreamObjects:(NSArray*)streams featured:(BOOL)featured;

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

- (void)loadTopGamesWithPageNumber:(NSInteger)pageNumber withCompletion: (void (^)(NSArray * result))completion {
    
    NSString * urlString = [NSString stringWithFormat:@"games/top?limit=25&offset=%@", @(pageNumber * 25)];
    
    [self.clientManager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary * responseDict = (NSDictionary *)responseObject;
        if(![responseObject isKindOfClass:[NSDictionary class]]
           || ![[responseDict allKeys] containsObject:@"top"]) {
            completion(nil);
            return;
        }
        
        NSArray * games = responseDict[@"top"];
        
        NSMutableArray * gameObjects = [[NSMutableArray alloc] init];
        for(NSDictionary * gameDict in games) {
            
            NSError * error = nil;
            TwitchGameListing * item = [MTLJSONAdapter modelOfClass:TwitchGameListing.class
                                                 fromJSONDictionary:gameDict error:&error];
            if(item && !error) {
                [gameObjects addObject:item];
                
            } else {
                if(error) {
                    NSLog(@"ERROR, loadTopGamesWithCompletion: %@", error);
                } else {
                    NSLog(@"ERROR, loadTopGamesWithCompletion: Unknown error");
                }
            }
        }
        completion(gameObjects);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"loadTopGamesWithCompletion, failure, %@", error);
    }];
}

- (void)loadTopGamesWithCompletion: (void (^)(NSArray * result))completion {
    [self loadTopGamesWithPageNumber:0 withCompletion:completion];
}

- (void)loadTopStreamsWithCompletion: (void (^)(NSArray * result))completion {
    [self loadTopStreamsWithGameFilter:nil withCompletion:completion];
}

- (void)loadTopStreamsWithGameFilter:(TwitchGame*)game withCompletion: (void (^)(NSArray * result))completion {
    
    NSDictionary * params = nil;
    if(game) {
        params = @{ @"game": game.name };
    }
    
    [self.clientManager GET:@"streams" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary * responseDict = (NSDictionary *)responseObject;
        if(![responseObject isKindOfClass:[NSDictionary class]]
           || ![[responseDict allKeys] containsObject:@"streams"]) {
            completion(nil);
            return;
        }
        completion([[self class] _processStreamObjects:responseDict[@"streams"] featured:NO]);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"loadTopStreamsWithCompletion, failure, %@", error);
    }];
}

- (void)loadFeaturedStreamsWithCompletion: (void (^)(NSArray * result))completion {
    
    [self.clientManager GET:@"streams/featured" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary * responseDict = (NSDictionary *)responseObject;
        if(![responseObject isKindOfClass:[NSDictionary class]]
           || ![[responseDict allKeys] containsObject:@"featured"]) {
            completion(nil);
            return;
        }
        completion([[self class] _processStreamObjects:responseDict[@"featured"] featured:YES]);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"loadTopStreamsWithCompletion, failure, %@", error);
    }];
}

- (void)loadTopVideosWithCompletion: (void (^)(NSArray * result))completion {
    [self.clientManager GET:@"videos/top" parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"loadTopStreamsWithCompletion, progress, %@", downloadProgress);
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"loadTopStreamsWithCompletion, success, %@", responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"loadTopStreamsWithCompletion, failure, %@", error);
    }];
}

- (void)loadAccessTokenForChannel:(TwitchChannel*)channel withCompletion: (void (^)(NSDictionary * result))completion {
    
    // /api/channels/c9sneaky/access_token
    NSString * urlStringForChannel = [NSString stringWithFormat:@"api/channels/%@/access_token", channel.name];
    
    if([[_accessTokenLookup allKeys] containsObject:channel.name]) {
        
        NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
        NSDictionary * cachedTokenResponse = _accessTokenLookup[channel.name];
        
        if([[cachedTokenResponse allKeys] containsObject:@"token"]) {
            
            NSError * error = nil;
            NSDictionary * tokenDict = [NSJSONSerialization JSONObjectWithData:[cachedTokenResponse[@"token"]
                                                                                dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
            if(tokenDict && !error && [[tokenDict allKeys] containsObject:@"expires"]) {
                
                NSTimeInterval cachedTokenResponseExpiry = [tokenDict[@"expires"] doubleValue];
                if(currentTime > cachedTokenResponseExpiry) {
                    
                    // Cached token has expired, remove from cache and retrieve new token from the network
                    NSLog(@"token has expired!");
                    [_accessTokenLookup removeObjectForKey:channel.name];
                    
                } else {
                    
                    // Cached token is valid, return without hitting the network
                    completion(cachedTokenResponse);
                    return;
                }
            }
        }
    }
    
    [self.accessTokenManager GET:urlStringForChannel parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
        
        _accessTokenLookup[channel.name] = responseObject;
        completion(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"ERROR: %@", error);
    }];
}

// Called sequentially after loadAccessTokenForChannel, providing the result of that method call
// as the 'token' parameter in this function call
+ (NSURL*)generateStreamingURLForChannel:(TwitchChannel*)channel withToken:(NSDictionary*)token {
    
    NSDictionary * params = @{ @"allow_source": @"true", @"allow_audio_only": @"true", @"allow_spectre": @"true", @"token": token[@"token"], @"sig": token[@"sig"] };
    NSString * paramsString = AFQueryStringFromParameters(params);
    
    NSString * urlStringForStreamURLRequest = [NSString stringWithFormat:@"%@/api/channel/hls/%@.m3u8?%@",
                                               kAPIUsherBaseURL, channel.name, paramsString];
    NSLog(@"urlStringForStreamURLRequest: %@", urlStringForStreamURLRequest);
    
    return [NSURL URLWithString:urlStringForStreamURLRequest];
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
+ (NSArray*)_processStreamObjects:(NSArray *)streams featured:(BOOL)featured {
    
    NSMutableArray * streamObjects = [[NSMutableArray alloc] init];
    for(NSDictionary * streamDict in streams) {
        
        NSError * error = nil;
        
        id item = nil;
        if(featured) {
            item = [MTLJSONAdapter modelOfClass:TwitchFeaturedStreamListing.class
                             fromJSONDictionary:streamDict error:&error];
        } else {
            item = [MTLJSONAdapter modelOfClass:TwitchStream.class
                             fromJSONDictionary:streamDict error:&error];
        }
    
        if(item && !error) {
            [streamObjects addObject:item];
            
        } else {
            if(error) {
                NSLog(@"ERROR, loadTopStreamsWithCompletion: %@", error);
            } else {
                NSLog(@"ERROR, loadTopStreamsWithCompletion: Unknown error");
            }
        }
    }
    return streamObjects;
}

@end
