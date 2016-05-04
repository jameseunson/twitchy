//
//  TwitchUser.h
//  Twitchy
//
//  Created by James Eunson on 4/05/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import <Mantle/Mantle.h>

// https://github.com/justintv/Twitch-API/blob/master/v3_resources/users.md#get-user
@interface TwitchUser : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong, readonly) NSString * type;
@property (nonatomic, strong, readonly) NSString * name;
@property (nonatomic, strong, readonly) NSDate * createdAt;
@property (nonatomic, strong, readonly) NSDate * updatedAt;
@property (nonatomic, strong, readonly) NSURL * logo;

@property (nonatomic, strong, readonly) NSNumber * userId;
@property (nonatomic, strong, readonly) NSString * displayName;
@property (nonatomic, strong, readonly) NSString * email;
@property (nonatomic, strong, readonly) NSNumber * partnered;
@property (nonatomic, strong, readonly) NSString * bio;

@end
