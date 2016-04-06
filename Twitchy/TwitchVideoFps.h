//
//  TwitchVideoFps.h
//  Twitchy
//
//  Created by James Eunson on 6/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface TwitchVideoFps : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong, readonly) NSNumber * audioOnly;
@property (nonatomic, strong, readonly) NSNumber * chunked;
@property (nonatomic, strong, readonly) NSNumber * high;
@property (nonatomic, strong, readonly) NSNumber * medium;
@property (nonatomic, strong, readonly) NSNumber * low;
@property (nonatomic, strong, readonly) NSNumber * mobile;

@end
