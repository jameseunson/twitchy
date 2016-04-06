//
//  TwitchVideoResolutions.h
//  Twitchy
//
//  Created by James Eunson on 6/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface TwitchVideoResolutions : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong, readonly) NSString * chunked;
@property (nonatomic, strong, readonly) NSString * high;
@property (nonatomic, strong, readonly) NSString * medium;
@property (nonatomic, strong, readonly) NSString * low;
@property (nonatomic, strong, readonly) NSString * mobile;

@end
