//
//  TwitchVideo.m
//  Twitchy
//
//  Created by James Eunson on 6/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "TwitchVideo.h"
#import "TwitchAPIClient.h"
#import "LoadingViewHelper.h"

static NSDateFormatter * _iso8601Formatter = nil;

@interface TwitchVideo ()
+ (NSDateFormatter*)iso8601Formatter;
@end

@implementation TwitchVideo

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) return nil;
    
    return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"videoId": @"_id",
             @"broadcastId": @"broadcast_id",
             @"broadcastType": @"broadcast_type",
             
             @"channel": @"channel",
             
             @"createdAt": @"created_at",
             @"videoDescription": @"description",
             
             @"fps": @"fps",
             @"game": @"game",
             @"length": @"length",
             @"preview": @"preview",
             
             @"recordedAt": @"recorded_at",
             
             @"resolutions": @"resolutions",
             
             @"status": @"status",
             @"tagList": @"tag_list",
             @"thumbnails": @"thumbnails",
             
             @"title": @"title",
             @"url": @"url",
             @"views": @"views",
             };
}

+ (NSValueTransformer *)channelJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:TwitchVideoChannel.class];
}
+ (NSValueTransformer *)fpsJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:TwitchVideoFps.class];
}
+ (NSValueTransformer *)resolutionsJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:TwitchVideoResolutions.class];
}
+ (NSValueTransformer *)thumbnailsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:TwitchVideoThumbnail.class];
}
+ (NSValueTransformer *)createdAtJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return [[[self class] iso8601Formatter] dateFromString:value];
    }];
}
+ (NSValueTransformer *)recordedAtJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return [[[self class] iso8601Formatter] dateFromString:value];
    }];
}

- (void)presentVideoInViewController:(UIViewController*)controller {
    
    [LoadingViewHelper addLoadingViewToContainerView:controller.view];
    
    [[TwitchAPIClient sharedClient] loadAccessTokenForVideo:self withCompletion:^(NSDictionary *result) {
        
        NSURL * streamingURL = [TwitchAPIClient generateVideoURLForVideo:self withToken:result];
        
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
