//
//  TwitchGame.m
//  Twitchy
//
//  Created by James Eunson on 4/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "TwitchGame.h"

@implementation TwitchGame

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) return nil;
    
    return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"box": @"box",
             @"logo": @"logo",
             @"gameId": @"_id",
             @"giantBombId": @"giantbomb_id",
             @"name": @"name",
             };
}
+ (NSValueTransformer *)boxJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:TwitchImage.class];
}
+ (NSValueTransformer *)logoJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:TwitchImage.class];
}

@end
