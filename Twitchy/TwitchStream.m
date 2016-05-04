//
//  TwitchStream.m
//  Twitchy
//
//  Created by James Eunson on 4/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "TwitchStream.h"
#import "TwitchAPIClient.h"
#import "LoadingViewHelper.h"

#import <GMIRCClient/GMIRCClient-umbrella.h>
#import "GMIRCClient-Swift.h"
#import "AppConfig.h"

static NSDateFormatter * _iso8601Formatter = nil;

@interface TwitchStream ()
+ (NSDateFormatter*)iso8601Formatter;
@end

@implementation TwitchStream

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) return nil;
    
    return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @"streamId": @"_id",
        @"averageFps": @"average_fps",
        @"channel": @"channel",
        @"createdAt": @"created_at",
        @"delay": @"delay",
        @"game": @"game",
        @"isPlaylist": @"is_playlist",
        @"preview": @"preview",
        @"videoHeight": @"video_height",
        @"viewers": @"viewers"
    };
}

+ (NSValueTransformer *)channelJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:TwitchChannel.class];
}
+ (NSValueTransformer *)previewJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:TwitchImage.class];
}
+ (NSValueTransformer *)createdAtJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return [[[self class] iso8601Formatter] dateFromString:value];
    }];
}

- (void)presentStreamInViewController:(UIViewController*)controller {
    
//    GMSocket * socket = [[GMSocket alloc] initWithHost:@"irc.chat.twitch.tv" port:6667];
//    GMIRCClient * client = [[GMIRCClient alloc] initWithSocket:socket];
//    
//    NSString * username = [[AppConfig sharedConfig] oAuthUsername];
//    client register:username user:<#(NSString * _Nonnull)#> realName:<#(NSString * _Nonnull)#> pass:<#(NSString * _Nonnull)#>
    
//    [client registerWithPassword:<#(NSString * _Nonnull)#> user:<#(NSString * _Nonnull)#> realName:<#(NSString * _Nonnull)#> pass:<#(NSString * _Nonnull)#>]
    
    [LoadingViewHelper addLoadingViewToContainerView:controller.view];
    
    [[TwitchAPIClient sharedClient] loadAccessTokenForChannel:self.channel withCompletion:^(NSDictionary *result) {

        NSURL * streamingURL = [TwitchAPIClient generateStreamingURLForChannel: self.channel withToken:result];
        
        AVPlayerViewController *viewController = [[AVPlayerViewController alloc] initWithNibName:nil bundle:nil];
        viewController.player = [[AVPlayer alloc] initWithURL:streamingURL];
        
        [LoadingViewHelper removeLoadingViewToContainerView:controller.view];
        
        [controller presentViewController:viewController animated:YES completion:^{
            [viewController.player play];
        }];
    }];
}

#pragma mark - Private Methods
+ (NSDateFormatter*)iso8601Formatter {
    
    if(_iso8601Formatter) {
        return _iso8601Formatter;
    }
    
    // Timestamps in JSON are returned in format 2016-03-16T05:29:00Z
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.locale = enUSPOSIXLocale;
    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    
    _iso8601Formatter = formatter;
    return _iso8601Formatter;
}


@end
