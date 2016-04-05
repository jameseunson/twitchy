//
//  TwitchFeaturedStreamListing.h
//  Twitchy
//
//  Created by James Eunson on 5/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "TwitchStream.h"

@interface TwitchFeaturedStreamListing : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSURL * image;
@property (nonatomic, strong) NSNumber * priority;
@property (nonatomic, strong) NSNumber * scheduled;
@property (nonatomic, strong) NSNumber * sponsored;

@property (nonatomic, strong) NSString * text;
@property (nonatomic, strong) NSString * title;

@property (nonatomic, strong) TwitchStream * stream;

@end
