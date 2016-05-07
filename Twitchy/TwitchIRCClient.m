//
//  TwitchIRCClient.m
//  Twitchy
//
//  Created by James Eunson on 7/05/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "TwitchIRCClient.h"
#import "AppConfig.h"

static TwitchIRCClient * _sharedClient = nil;

@interface TwitchIRCClient ()

@property (nonatomic, assign) BOOL readyToJoinChannel;

@property (nonatomic, strong) NSMutableDictionary * emoticonLookup;
@property (nonatomic, strong) NSRegularExpression * emoticonRegex;

- (void)_emoticonDataLoaded:(NSNotification*)notification;
- (void)loadEmoticonData;

@property (nonatomic, assign) BOOL emoticonLookupAssembled;

@end

@implementation TwitchIRCClient

+ (TwitchIRCClient*)sharedClient {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[TwitchIRCClient alloc] init];
    });
    return _sharedClient;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if(self) {
        
        _emoticonLookupAssembled = NO;
        _readyToJoinChannel = NO;
        
        self.socket = [[GMSocket alloc] initWithHost:kIRCBaseURL port:kIRCPort];
        self.client = [[GMIRCClient alloc] initWithSocket:_socket];
        _client.delegate = self;
        
        self.messages = [[NSMutableArray alloc] init];
        self.emoticonLookup = [[NSMutableDictionary alloc] init];
        
        NSString * username = [[AppConfig sharedConfig] oAuthUsername];
        NSString * token = [[AppConfig sharedConfig] oAuthToken];
        token = [NSString stringWithFormat:@"oauth:%@", token];
        
        [_client registerWithNickname:username pass:token];
        
        if([[AppConfig sharedConfig] streamChatEmoticonsDownloadFinished]) {
            [self loadEmoticonData];
            
        } else {
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_emoticonDataLoaded:)
                                                         name:kTwitchAPIClientEmoticonsFinishedLoadingNotification object:nil];
        }
    }
    return self;
}

- (void)joinChannel:(NSString*)name {
    
    if(!_readyToJoinChannel) {
        NSLog(@"TwitchIRCClient, Attempted joinChannel while !_readyToJoinChannel");
        return;
    }
    
    [_messages removeAllObjects];
    
    NSLog(@"TwitchIRCClient, joinChannel: %@", name);
    [_client join:name];
}

- (void)leaveChannel:(NSString*)name {
    [_client leave:name];
}

#pragma mark - GMIRCClientDelegate Methods

// When this method is called, the channel is ready At this point you can join a chat room
- (void)didWelcome {
    _readyToJoinChannel = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:
        kTwitchIRCClientReadyToJoinChannelNotification object:nil];
}

// Called when successfully joined a chat room @param channel Prepend an hash symbol (#) to the chat room name, e.g. "#test"
- (void)didJoin:(NSString * _Nonnull)channel {}

- (void)didLeave:(NSString * _Nonnull)channel {}

// Called when someone sent you a private message @param text The text sent by the user @param from The nickName of who sent you the message
- (void)didReceivePrivateMessage:(NSString * _Nonnull)text from:(NSString * _Nonnull)from {
    
    NSMutableDictionary * message = [@{ @"from": from, @"text": text } mutableCopy];
    
    if([_messages count] >= 20) {
        [_messages removeObjectAtIndex:0];
    }
    
    if(_emoticonLookupAssembled) {
        
        NSArray* matches = [self.emoticonRegex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
        if([matches count] > 0) {
         
            NSMutableAttributedString * mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:text];
            
            for ( NSTextCheckingResult* match in matches ) {
                
                NSString* matchText = [text substringWithRange:[match range]];
                
                // The > 1 is to filter out random letter 'S' and 'R' matches I've been getting, don't fully understand why
                if([[_emoticonLookup allKeys] containsObject:matchText] && [matchText length] > 1) {
                    NSLog(@"didReceivePrivateMessage, match (%lu): %@", [matches count], matchText);
                    
                    @try {
                        NSDictionary * imageDataForEmoticon = _emoticonLookup[matchText];
                        NSURL * url = [NSURL URLWithString:imageDataForEmoticon[@"url"]];
                        
                        __block NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                        textAttachment.image = [[UIImage alloc] init];
                        
                        // Load emoticon image asynchronously, replacing the text with the image
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            NSError * error = nil;
                            
                            NSData * imageData = [[NSData alloc] initWithContentsOfURL:url options:0 error:&error];
                            UIImage * image = [[UIImage alloc] initWithData:imageData];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                textAttachment.image = image;
                                textAttachment.bounds = CGRectMake(0, 0, textAttachment.image.size.width * 2, textAttachment.image.size.height * 2);

                                // Tell StreamChatViewController to refresh UITableView
                                [[NSNotificationCenter defaultCenter] postNotificationName:
                                    kTwitchIRCClientDownloadedEmoticonImageNotification object:nil];
                            });
                        });
                        
                        NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
                        [mutableAttributedString replaceCharactersInRange:[match range] withAttributedString:attrStringWithImage];
                        
                        message[@"text"] = mutableAttributedString;
                        
                    } @catch (NSException *exception) {
                        NSLog(@"didReceivePrivateMessage, ERROR: %@", exception);
                    }
                }
            }
        }
    }
    
    [_messages addObject:message];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:
        kTwitchIRCClientReceivedMessageNotification object:message];
}

- (void)didReceiveMessage:(GMIRCMessage *)message {}

#pragma mark - Private Methods
- (void)loadEmoticonData {
    
    // Already loaded
    if(_emoticonLookupAssembled) {
        return;
    }
    
    // Load from scratch
    [[TwitchAPIClient sharedClient] loadChatEmoticonsWithCompletion:^(NSString *result) {
//        NSLog(@"loadChatEmoticonsWithCompletion: %@", result);
        if(!result) {
            return;
        }
        
        NSError * error = nil;
        NSDictionary * responseDict = [NSJSONSerialization JSONObjectWithData:
                                       [result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        if(!responseDict || ![[responseDict allKeys] containsObject:@"emoticons"]) {
            NSLog(@"ERROR: loadEmoticonData: %@", error);
            return;
        }
        NSArray * emoticons = responseDict[@"emoticons"];
        
        // Just in case we access a key that doesn't exist
        @try {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                for(NSDictionary * emoticon in emoticons) {
                    
                    NSArray * images = emoticon[@"images"];
                    NSDictionary * image = [images firstObject];
//                    NSString * imageUrl = image;
                    
                    _emoticonLookup[emoticon[@"regex"]] = image;
                }
                NSString * emoticonRegexString = [[[_emoticonLookup allKeys] sortedArrayUsingSelector:
                                             @selector(localizedCaseInsensitiveCompare:)] componentsJoinedByString:@"|"];
                NSError* error = nil;
                self.emoticonRegex = [NSRegularExpression regularExpressionWithPattern:
                                              emoticonRegexString options:0 error:&error];
                _emoticonLookupAssembled = YES;
                NSLog(@"_emoticonLookupAssembled: YES, ERROR: %@", error);
            });
            
        } @catch(NSException * e) {
            NSLog(@"ERROR: loadEmoticonData: %@", e);
        }
    }];
}

- (void)_emoticonDataLoaded:(NSNotification*)notification {
    [self loadEmoticonData];
}

@end
