//
//  TwitchFeaturedStreamListing.m
//  Twitchy
//
//  Created by James Eunson on 5/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "TwitchFeaturedStreamListing.h"

@implementation TwitchFeaturedStreamListing

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) return nil;
    
    return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"image": @"image",
             @"priority": @"priority",
             @"scheduled": @"scheduled",
             @"sponsored": @"sponsored",
             @"title": @"title",
             @"text": @"text",
             @"stream": @"stream",
             };
}

+ (NSValueTransformer *)streamJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:TwitchStream.class];
}
+ (NSValueTransformer *)imageJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return [NSURL URLWithString:value];
    }];
}

@end
