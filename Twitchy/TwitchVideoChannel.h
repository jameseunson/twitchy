//
//  TwitchVideoChannel.h
//  Twitchy
//
//  Created by James Eunson on 6/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface TwitchVideoChannel : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong, readonly) NSString * name;
@property (nonatomic, strong, readonly) NSString * displayName;

@end
