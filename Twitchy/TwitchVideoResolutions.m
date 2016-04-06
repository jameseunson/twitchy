//
//  TwitchVideoResolutions.m
//  Twitchy
//
//  Created by James Eunson on 6/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "TwitchVideoResolutions.h"

@implementation TwitchVideoResolutions

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) return nil;
    
    return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"chunked": @"chunked",
             @"high": @"high",
             @"medium": @"medium",
             @"low": @"low",
             @"mobile": @"mobile",
             };
}


@end
