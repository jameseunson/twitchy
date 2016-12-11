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
#import <CommonCrypto/CommonDigest.h>
#import "AppConfig.h"
#import "AppDelegate.h"

#define kEmoticonsFilename @"emoticons.json"

static TwitchAPIClient * _sharedClient = nil;

@interface TwitchAPIClient ()

@property (nonatomic, strong, readonly) AFHTTPSessionManager * clientManager;
@property (nonatomic, strong, readonly) AFHTTPSessionManager * accessTokenManager;
@property (nonatomic, strong, readonly) AFHTTPSessionManager * backendManager;
@property (nonatomic, strong, readonly) AFHTTPSessionManager * emoticonsManager;

@property (nonatomic, strong) NSMutableDictionary * accessTokenLookup;

+ (NSArray*)_processResponseObject:(NSArray *)streams class:(Class)class;
- (NSDictionary*)_getCachedAuthorizationTokenForKey:(NSString*)key;
+ (NSString*)_generateSHA1Hash:(NSString *)string;

@end

@implementation TwitchAPIClient
@synthesize clientManager = _clientManager;
@synthesize accessTokenManager = _accessTokenManager;
@synthesize backendManager = _backendManager;
@synthesize emoticonsManager = _emoticonsManager;

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

- (void)loadTopGamesWithCompletion: (void (^)(NSArray * result, BOOL pagesRemaining))completion {
    [self loadTopGamesWithPageNumber:0 withCompletion:completion];
}

- (void)loadTopStreamsWithCompletion: (void (^)(NSArray * result, BOOL pagesRemaining))completion {
    [self loadTopStreamsWithGameFilter:nil withPageNumber:0 withCompletion:completion];
}

- (void)loadTopStreamsWithGameFilter:(TwitchGame*)game withCompletion: (void (^)(NSArray * result, BOOL pagesRemaining))completion {
    [self loadTopStreamsWithGameFilter:game withPageNumber:0 withCompletion:completion];
}

#pragma mark - Streams
- (void)loadTopStreamsWithGameFilter:(TwitchGame*)game withPageNumber:(NSInteger)pageNumber withCompletion: (void (^)(NSArray * result, BOOL pagesRemaining))completion {
    NSDictionary * params = nil;
    if(game) {
        params = @{ @"game": game.name };
    }
    
    NSString * urlString = [NSString stringWithFormat:@"streams?limit=25&offset=%@", @(pageNumber * 25)];
    
    [self.clientManager GET:urlString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary * responseDict = (NSDictionary *)responseObject;
        if(![responseObject isKindOfClass:[NSDictionary class]]
           || ![[responseDict allKeys] containsObject:@"streams"]) {
            completion(nil, NO);
            return;
        }
        
        NSInteger totalStreamsCount = [responseDict[@"_total"] integerValue];
        float totalPageCount = ceilf( (float)totalStreamsCount / (float)25 );
        
        BOOL pagesRemainingToLoad = YES;
        if((pageNumber + 1) == ((NSInteger)totalPageCount)) {
            pagesRemainingToLoad = NO;
        }
        
        completion([[self class] _processResponseObject:responseDict[@"streams"] class:TwitchStream.class],
                   pagesRemainingToLoad);
        
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
- (void)loadTopVideosWithCompletion: (void (^)(NSArray * result, BOOL pagesRemaining))completion {
    [self loadTopVideosWithPageNumber:0 withCompletion:completion];
}

- (void)loadTopVideosWithPageNumber:(NSInteger)pageNumber withCompletion: (void (^)(NSArray * result, BOOL pagesRemaining))completion {
    
    NSString * urlString = [NSString stringWithFormat:@"videos/top?limit=25&offset=%@", @(pageNumber * 25)];
    
    [self.clientManager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary * responseDict = (NSDictionary *)responseObject;
        if(![responseObject isKindOfClass:[NSDictionary class]]
           || ![[responseDict allKeys] containsObject:@"videos"]) {
            completion(nil, NO);
            return;
        }
        NSInteger totalStreamsCount = [responseDict[@"_total"] integerValue];
        float totalPageCount = ceilf( (float)totalStreamsCount / (float)25 );
        
        BOOL pagesRemainingToLoad = YES;
        if((pageNumber + 1) == ((NSInteger)totalPageCount)) {
            pagesRemainingToLoad = NO;
        }
        
        completion([[self class] _processResponseObject:responseDict[@"videos"] class:TwitchVideo.class],
                   pagesRemainingToLoad);
        
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
        
        NSDictionary * userInfo = error.userInfo;
        
        NSData * data = userInfo[@"com.alamofire.serialization.response.error.data"];
        NSString * responseErrorString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSLog(@"%@, %@", userInfo, responseErrorString);
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

#pragma mark - Chat Emoticons
- (void)loadChatEmoticonsWithCompletion:(void (^)(NSString * result))completion {
    
    if([[AppConfig sharedConfig] streamChatEmoticonsDownloadStarted] &&
       ![[AppConfig sharedConfig] streamChatEmoticonsDownloadFinished]) {
        NSLog(@"ERROR: loadChatEmoticonsWithCompletion called while download is in progress");
        completion(nil);
    }
    
    NSFileManager * fm = [NSFileManager defaultManager];
    NSString * documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString * filePath = [NSString stringWithFormat:@"%@/%@", documentsPath, kEmoticonsFilename];
    
    if([[AppConfig sharedConfig] streamChatEmoticonsDownloadFinished]) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSError * error = nil;
            NSString * responseString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
            if(error) {
                NSLog(@"loadChatEmoticonsWithCompletion: %@", error);
            }
            
            completion(responseString);
        });
        
    } else {
        
        [[AppConfig sharedConfig] setBool:YES forKey:kStreamChatEmoticonsDownloadStarted];
        
        [self.emoticonsManager GET:@"chat/emoticons" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"loadChatEmoticonsWithCompletion: %@", responseObject);
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                
                if(![fm isWritableFileAtPath:documentsPath]) {
                    NSLog(@"ERROR: Storage directory not writable");
                    return;
                }
                NSData * responseData = (NSData*)responseObject;
                
                [fm createFileAtPath:filePath contents:responseData attributes:nil];
                
                NSLog(@"loadChatEmoticonsWithCompletion, file written");
                [[AppConfig sharedConfig] setBool:YES forKey:kStreamChatEmoticonsDownloadFinished];
                [[NSNotificationCenter defaultCenter] postNotificationName:
                    kTwitchAPIClientEmoticonsFinishedLoadingNotification object:nil];
                
                NSString * responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                completion(responseString);
            });
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"loadChatEmoticonsWithCompletion, failure, %@", error);
            [[AppConfig sharedConfig] setBool:NO forKey:kStreamChatEmoticonsDownloadStarted];
            completion(nil);
        }];
    }
}

#pragma mark - OAuth Authentication
- (void)getOAuthTokenWithCompletion: (void (^)(NSDictionary * result))completion {
    
    [self.backendManager POST:@"code" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil);
    }];
}

- (void)checkOAuthAuthenticationStatusWithCode:(NSString*)code completion: (void (^)(NSDictionary * result))completion {
    
    // This is basic security via a HMAC, both the server and client have the Twitch API secret
    // so we can use that as the private key to generate the HMAC, by hashing the code using SHA-1
    NSString * codeHash = [NSString stringWithFormat:@"%@%@", code, kAPIClientSecret];
    codeHash = [[self class] _generateSHA1Hash:codeHash];
    
    NSString * urlString = [NSString stringWithFormat:@"code/status/%@/%@", code, codeHash];
    NSLog(@"urlString: %@", urlString);
    
    [self.backendManager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil);
    }];
}

#pragma mark - OAuth Logged In Methods
- (void)loadUserDetails: (void (^)(TwitchUser * result))completion {
    
    if(![[AppConfig sharedConfig] oAuthToken]) {
        completion(nil); return;
    }
    
    NSDictionary * params = @{ @"oauth_token": [[AppConfig sharedConfig] oAuthToken] };
    [self.clientManager GET:@"user" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSArray * objs = [[self class] _processResponseObject:@[ responseObject ] class:TwitchUser.class];
        TwitchUser * user = [objs firstObject];
        
        completion(user);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil);
    }];
}

- (void)loadUserFollowedStreamsWithPageNumber:(NSInteger)pageNumber withCompletion:(void (^)(NSArray * result, BOOL pagesRemaining))completion {
 
    if(![[AppConfig sharedConfig] oAuthToken]) {
        completion(nil, NO); return;
    }
    
    NSString * urlString = [NSString stringWithFormat:@"streams/followed?limit=25&offset=%@", @(pageNumber * 25)];
    
    NSDictionary * params = @{ @"oauth_token": [[AppConfig sharedConfig] oAuthToken] };
    [self.clientManager GET:urlString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary * responseDict = (NSDictionary *)responseObject;
        
        if(![responseObject isKindOfClass:[NSDictionary class]]
           || ![[responseDict allKeys] containsObject:@"streams"]) {
            completion(nil, NO);
            return;
        }
        
        NSInteger totalStreamsCount = [responseDict[@"_total"] integerValue];
        float totalPageCount = ceilf( (float)totalStreamsCount / (float)25 );
        
        BOOL pagesRemainingToLoad = YES;
        if((pageNumber + 1) == ((NSInteger)totalPageCount)) {
            pagesRemainingToLoad = NO;
        }
        NSLog(@"currentPage = %lu, totalPages: %f, pagesRemaining: %d", pageNumber, totalPageCount, pagesRemainingToLoad);
        
        completion([[self class] _processResponseObject:responseDict[@"streams"] class:TwitchStream.class], pagesRemainingToLoad);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"loadUserFollowedStreamsWithCompletion: %@", error);
        
        if([[error localizedDescription] containsString:@"401"]) {
            AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            [delegate revertLogin];
        }
        completion(nil, NO);
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
    
    AFHTTPRequestSerializer * requestSerializer = [AFHTTPRequestSerializer serializer];
    [requestSerializer setValue:kAPIClientID forHTTPHeaderField:@"Client-ID"];
    
    _accessTokenManager.requestSerializer = requestSerializer;
    
    return _accessTokenManager;
}

- (AFHTTPSessionManager*)backendManager {
    
    if(_backendManager) {
        return _backendManager;
    }
    _backendManager = [[AFHTTPSessionManager alloc] initWithBaseURL:
                           [NSURL URLWithString:kAPITwitchyBackendURL]
                                                   sessionConfiguration:
                           [NSURLSessionConfiguration defaultSessionConfiguration]];
    return _backendManager;
}
- (AFHTTPSessionManager*)emoticonsManager {
    
    if(_emoticonsManager) {
        return _emoticonsManager;
    }
    _emoticonsManager = [[AFHTTPSessionManager alloc] initWithBaseURL:
                       [NSURL URLWithString:kAPIBaseURL]
                                               sessionConfiguration:
                       [NSURLSessionConfiguration defaultSessionConfiguration]];
    
    _emoticonsManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    _emoticonsManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    return _emoticonsManager;
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

// https://stackoverflow.com/questions/735714/iphone-and-hmac-sha-1-encoding
// Ideally there would just be a SHA1Hash() helper function, but alas no
+ (NSString*)_generateSHA1Hash:(NSString *)string {
    
    const char *s = [string cStringUsingEncoding:NSASCIIStringEncoding];
    NSData *keyData = [NSData dataWithBytes:s length:strlen(s)];
    
    // This is the destination
    uint8_t digest[CC_SHA1_DIGEST_LENGTH] = {0};
    // This one function does an unkeyed SHA1 hash of your hash data
    CC_SHA1(keyData.bytes, (CC_LONG)keyData.length, digest);
    
    // Now convert to NSData structure to make it usable again
    NSData *out = [NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
    // description converts to hex but puts <> around it and spaces every 4 bytes
    NSString *hash = out.description;
    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    return hash;
}

@end
