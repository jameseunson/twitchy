//
//  StreamWatchViewController.m
//  Twitchy
//
//  Created by James Eunson on 4/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "StreamWatchViewController.h"
#import "TwitchAPIClient.h"

@interface StreamWatchViewController ()

@end

@implementation StreamWatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.playbackController = [[AVPlayerViewController alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:_playbackController];
    [self.view addSubview:_playbackController.view];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName: @"Main" bundle:[NSBundle mainBundle]];
    self.chatController = [storyboard instantiateViewControllerWithIdentifier:@"StreamChatViewController"];
    
    _chatController.stream = self.stream;
    
    [self addChildViewController:_chatController];
    [self.view addSubview:_chatController.view];
    
    [[TwitchAPIClient sharedClient] loadAccessTokenForChannel:self.stream.channel withCompletion:^(NSDictionary *result) {
        
        NSURL * streamingURL = [TwitchAPIClient generateStreamingURLForChannel: self.stream.channel withToken:result];
        _playbackController.player = [[AVPlayer alloc] initWithURL:streamingURL];
        [_playbackController.player play];
    }];
    
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat chatControllerViewWidth = roundf(self.view.frame.size.width / 3);
    
    self.chatController.view.frame = CGRectMake(0, 0, chatControllerViewWidth,
                                                self.view.frame.size.height);
    
    self.playbackController.view.frame = CGRectMake(0, 0, self.view.frame.size.width,
                                                self.view.frame.size.height);
}

@end
