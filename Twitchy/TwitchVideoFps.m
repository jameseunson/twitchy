//
//  TwitchVideoFps.m
//  Twitchy
//
//  Created by James Eunson on 6/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "TwitchVideoFps.h"

@implementation TwitchVideoFps

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) return nil;
    
    return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"audioOnly": @"audio_only",
             @"chunked": @"chunked",
             @"high": @"high",
             @"medium": @"medium",
             @"low": @"low",
             @"mobile": @"mobile",
             };
}

@end
