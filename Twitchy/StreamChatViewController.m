//
//  StreamChatViewController.m
//  Twitchy
//
//  Created by James Eunson on 6/05/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "StreamChatViewController.h"
#import "AppConfig.h"
#import "StreamChatTableViewCell.h"
#import "TwitchAPIClient.h"
#import "TwitchIRCClient.h"

#define kStreamChatCellReuseIdentifier @"streamChatCellReuseIdentifier"

@interface StreamChatViewController ()

- (void)_loggedIntoIRCServer:(NSNotification*)notification;
- (void)_chatMessageReceived:(NSNotification*)notification;
- (void)_chatEmoticonDownloaded:(NSNotification*)notification;

@end

@implementation StreamChatViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_loggedIntoIRCServer:)
//                                                     name:kTwitchIRCClientReadyToJoinChannelNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_chatMessageReceived:)
//                                                     name:kTwitchIRCClientReceivedMessageNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_chatEmoticonDownloaded:)
//                                                     name:kTwitchIRCClientDownloadedEmoticonImageNotification object:nil];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    
    [self.tableView registerClass:[StreamChatTableViewCell class]
           forCellReuseIdentifier:kStreamChatCellReuseIdentifier];
    self.tableView.userInteractionEnabled = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Chat";
    self.tableView.contentInset = UIEdgeInsetsMake(20.0f, 10.0f, 0, 10.0f);
    
//    if(![[AppConfig sharedConfig] streamChatEmoticonsDownloadStarted]) {
//        [[TwitchAPIClient sharedClient] loadChatEmoticonsWithCompletion:^(NSString *result) {
////            NSLog(@"loadChatEmoticonsWithCompletion: %@", result);
//        }];
//    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
//    NSString * channelName = [NSString stringWithFormat: @"#%@", _stream.channel.name];
//    [[TwitchIRCClient sharedClient] leaveChannel:channelName];
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[TwitchIRCClient sharedClient].messages count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary * message = [TwitchIRCClient sharedClient].messages[indexPath.row];
    
    StreamChatTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:
                              kStreamChatCellReuseIdentifier forIndexPath:indexPath];
    cell.message = message;
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary * message = [TwitchIRCClient sharedClient].messages[indexPath.row];
    
    // -20.0f takes into account left and right content offset
    CGFloat heightForRow = [StreamChatTableViewCell heightWithMessage:message
                                                            withWidth:tableView.frame.size.width - 20.0f];
    
    return heightForRow;
}

#pragma mark - Private Methods
- (void)_loggedIntoIRCServer:(NSNotification*)notification {
    
    NSString * channelName = [NSString stringWithFormat: @"#%@", _stream.channel.name];
    [[TwitchIRCClient sharedClient] joinChannel:channelName];
}

- (void)_chatMessageReceived:(NSNotification*)notification {
    
    [self.tableView reloadData];
    
    NSIndexPath * lastMessageIndexPath = [NSIndexPath indexPathForRow:
                                          ([[TwitchIRCClient sharedClient].messages count] - 1) inSection:0];
    [self.tableView scrollToRowAtIndexPath:lastMessageIndexPath
                          atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)_chatEmoticonDownloaded:(NSNotification*)notification {
    [self.tableView reloadData];
}

@end
