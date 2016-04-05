//
//  TwitchGameListing.m
//  Twitchy
//
//  Created by James Eunson on 4/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "TwitchGameListing.h"

@implementation TwitchGameListing

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) return nil;
    
    return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"viewers":  @"viewers",
             @"game":     @"game",
             @"channels": @"channels",
             };
}
+ (NSValueTransformer *)gameJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:TwitchGame.class];
}

@end
