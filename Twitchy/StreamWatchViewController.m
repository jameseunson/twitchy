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
    
    self.chatController = [self.viewControllers firstObject];
    _chatController.stream = self.stream;

    NSArray * viewControllers = [self.viewControllers mutableCopy];
    NSMutableArray * mutableViewControllers = [viewControllers mutableCopy];
    [mutableViewControllers removeObject:[mutableViewControllers lastObject]];
    
    AVPlayerViewController *viewController = [[AVPlayerViewController alloc] initWithNibName:nil bundle:nil];
    [mutableViewControllers addObject: viewController];
    
    self.viewControllers = mutableViewControllers;
    
    [[TwitchAPIClient sharedClient] loadAccessTokenForChannel:self.stream.channel withCompletion:^(NSDictionary *result) {
        
        NSURL * streamingURL = [TwitchAPIClient generateStreamingURLForChannel: self.stream.channel withToken:result];
        viewController.player = [[AVPlayer alloc] initWithURL:streamingURL];
        [viewController.player play];
        
//        [LoadingViewHelper removeLoadingViewToContainerView:controller.view];
        
//        [controller presentViewController:viewController animated:YES completion:^{
//            [viewController.player play];
//        }];
        
        
    }];
    
    self.view.backgroundColor = [UIColor blackColor];
}

@end
