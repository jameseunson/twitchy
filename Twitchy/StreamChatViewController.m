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

#define kStreamChatCellReuseIdentifier @"streamChatCellReuseIdentifier"

@interface StreamChatViewController ()

@property (nonatomic, strong) NSMutableArray * messages;

@end

@implementation StreamChatViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        self.messages = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.tableView registerClass:[StreamChatTableViewCell class]
           forCellReuseIdentifier:kStreamChatCellReuseIdentifier];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Chat";
    
    self.socket = [[GMSocket alloc] initWithHost:@"irc.chat.twitch.tv" port:6667];
    self.client = [[GMIRCClient alloc] initWithSocket:_socket];
    _client.delegate = self;
    
    NSString * username = [[AppConfig sharedConfig] oAuthUsername];
    NSString * token = [[AppConfig sharedConfig] oAuthToken];
    token = [NSString stringWithFormat:@"oauth:%@", token];
    
    [_client registerWithNickname:username pass:token];
    
    NSLog(@"%@", NSStringFromCGRect(self.tableView.frame));
    
    self.tableView.contentInset = UIEdgeInsetsMake(20.0f, 10.0f, 0, 0);
}

#pragma mark - GMIRCClientDelegate Methods
/// When this method is called, the channel is ready At this point you can join a chat room
- (void)didWelcome {
    NSLog(@"GMIRCClientDelegate, didWelcome");
    
    NSString * channelName = [NSString stringWithFormat: @"#%@", _stream.channel.name];
    NSLog(@"joining: %@", channelName);
    
    [_client join:channelName];
}

/// Called when successfully joined a chat room @param channel Prepend an hash symbol (#) to the chat room name, e.g. "#test"
- (void)didJoin:(NSString * _Nonnull)channel {
    NSLog(@"GMIRCClientDelegate, didJoin: %@", channel);
}

/// Called when someone sent you a private message @param text The text sent by the user @param from The nickName of who sent you the message
- (void)didReceivePrivateMessage:(NSString * _Nonnull)text from:(NSString * _Nonnull)from {
    NSLog(@"GMIRCClientDelegate, didReceivePrivateMessage: %@, %@", text, from);
    
    NSDictionary * message = @{ @"from": from, @"text": text };
    
    [_messages addObject:message];
    [self.tableView reloadData];
    
    NSIndexPath * lastMessageIndexPath = [NSIndexPath indexPathForRow:([_messages count] - 1) inSection:0];
    [self.tableView scrollToRowAtIndexPath:lastMessageIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)didReceiveMessage:(GMIRCMessage *)message {
    NSLog(@"GMIRCClientDelegate, didReceiveMessage: %@", message);
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_messages count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary * message = _messages[indexPath.row];
    
    StreamChatTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:
                              kStreamChatCellReuseIdentifier forIndexPath:indexPath];
    cell.message = message;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor blackColor];
}

#pragma mark - UITableViewDelegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary * message = _messages[indexPath.row];
    CGFloat heightForRow = [StreamChatTableViewCell heightWithMessage:message withWidth:tableView.frame.size.width];
    NSLog(@"heightForRow: %f", heightForRow);
    
    return heightForRow;
}

@end
