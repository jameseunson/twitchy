//
//  TwitchStreamPreview.h
//  Twitchy
//
//  Created by James Eunson on 4/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface TwitchImage : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong, readonly) NSURL * large;
@property (nonatomic, strong, readonly) NSURL * medium;
@property (nonatomic, strong, readonly) NSURL * small;

@end
