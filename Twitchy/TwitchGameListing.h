//
//  TwitchGameListing.h
//  Twitchy
//
//  Created by James Eunson on 4/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "TwitchGame.h"

@interface TwitchGameListing : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSNumber * channels;
@property (nonatomic, strong) NSNumber * viewers;

@property (nonatomic, strong) TwitchGame * game;

@end
