//
//  TwitchUser.m
//  Twitchy
//
//  Created by James Eunson on 4/05/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "TwitchUser.h"

static NSDateFormatter * _iso8601Formatter = nil;

@interface TwitchUser ()
+ (NSDateFormatter*)iso8601Formatter;
@end

@implementation TwitchUser

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) return nil;
    
    return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"type": @"type",
             @"name": @"name",
             @"createdAt": @"created_at",
             @"updatedAt": @"updated_at",
             @"logo": @"logo",
             @"userId": @"_id",
             @"displayName": @"display_name",
             @"email": @"email",
             @"partnered": @"partnered",
             @"bio": @"bio",
             };
}
+ (NSValueTransformer *)createdAtJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return [[[self class] iso8601Formatter] dateFromString:value];
    }];
}
+ (NSValueTransformer *)updatedAtJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return [[[self class] iso8601Formatter] dateFromString:value];
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
