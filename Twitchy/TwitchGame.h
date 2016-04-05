//
//  TwitchGame.h
//  Twitchy
//
//  Created by James Eunson on 4/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import <Mantle/Mantle.h>

#import "TwitchImage.h"

@interface TwitchGame : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong, readonly) TwitchImage * box;
@property (nonatomic, strong, readonly) TwitchImage * logo;

@property (nonatomic, strong, readonly) NSNumber * gameId;
@property (nonatomic, strong, readonly) NSNumber * giantBombId;
@property (nonatomic, strong, readonly) NSString * name;

@end
