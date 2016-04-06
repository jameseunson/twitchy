//
//  TwitchVideoThumbnail.h
//  Twitchy
//
//  Created by James Eunson on 6/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface TwitchVideoThumbnail : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong, readonly) NSString * type;
@property (nonatomic, strong, readonly) NSURL * url;

@end
