//
//  AccountViewController.m
//  Twitchy
//
//  Created by James Eunson on 3/05/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "AccountViewController.h"
#import "TwitchAPIClient.h"
#import "AppConfig.h"

@interface AccountViewController ()

- (void)doLogin;
- (void)displayCode;
- (void)displayLoggedInView;

- (void)displayErrorAlert;

- (void)startCheckForAuthentication;
- (void)stopCheckForAuthentication;

// NSTimer method
- (void)checkAuthentication:(id)sender;

// Target action methods
- (void)didTapLoginButton:(id)sender;
- (void)didTapLoggedInButton:(id)sender;

@property (nonatomic, strong) NSTimer * checkTimer;
@property (nonatomic, strong) NSString * code;

@end

@implementation AccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Elements for code display view
    _codeLabel.hidden = _codeAboveDescriptionLabel.hidden =
        _codeBelowDescriptionLabel.hidden = _loadingView.hidden = YES;
    
    // Elements for success view
    _loggedInLabel.hidden = _loggedInImageView.hidden =
        _loggedInButton.hidden = YES;
    
    [_loginButton addTarget:self action:@selector(didTapLoginButton:)
           forControlEvents:UIControlEventPrimaryActionTriggered];
    
    [_loggedInButton addTarget:self action:@selector(didTapLoggedInButton:)
           forControlEvents:UIControlEventPrimaryActionTriggered];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self stopCheckForAuthentication];
}

// Display loading indicator and start server token
// query when animation is done
- (void)didTapLoginButton:(id)sender {
    NSLog(@"didTapLoginButton");
    
    [UIView animateWithDuration:0.3 animations:^{
        _loginButton.alpha = 0;
        
    } completion:^(BOOL finished) {
        if(finished) {
            _loginButton.hidden = YES;
        }
        
        [_loadingView startAnimating];
        _loadingView.alpha = 0;
        _loadingView.hidden = NO;
        
        [UIView animateWithDuration:0.3 animations:^{
            _loadingView.alpha = 1;
        } completion:^(BOOL finished) {
            if(finished) {
                [self doLogin];
            }
        }];
    }];
}

- (void)didTapLoggedInButton:(id)sender {
    NSLog(@"didTapLoggedInButton");
    
    
}

// Request token from server and display code on screen when token is received
- (void)doLogin {
    
    NSLog(@"AccountViewController, doLogin");
    
    [[TwitchAPIClient sharedClient] getOAuthTokenWithCompletion:^(NSDictionary *result) {
        NSLog(@"AccountViewController, getOAuthTokenWithCompletion: %@", result);
        
        [_loadingView stopAnimating];
        [UIView animateWithDuration:0.3 animations:^{
            _loadingView.alpha = 0;
            
        } completion:^(BOOL finished) {
            
            if(finished) {
                
                if(result && [[result allKeys] containsObject:@"code"]
                   && result[@"code"] && [result[@"code"] length] > 0) {
                    
                    self.code = result[@"code"];
                    [self displayCode];
                    
                } else {
                    
                    NSLog(@"ERROR, AccountViewController, getOAuthTokenWithCompletion");
                    [self displayErrorAlert];
                }
            }
        }];
        
    }];
}

// Display all code-related visual elements and start 5 second short poll
// for authentication confirmation
- (void)displayCode {
    
    // Make uppercase and insert space after 4th character turning 2939b101
    // into 2939 B101, easier to remember, enter
    NSMutableString * mutableCode = [[_code uppercaseString] mutableCopy];
    [mutableCode insertString:@" " atIndex:4];
    
    _codeLabel.text = [mutableCode copy];
    
    // Display visual code elements
    _codeLabel.alpha = _codeAboveDescriptionLabel.alpha =
    _codeBelowDescriptionLabel.alpha = 0;
    
    _codeLabel.hidden = _codeAboveDescriptionLabel.hidden =
    _codeBelowDescriptionLabel.hidden = NO;
    
    [UIView animateWithDuration:0.3 animations:^{
        _codeLabel.alpha = _codeAboveDescriptionLabel.alpha =
        _codeBelowDescriptionLabel.alpha = 1;
    } completion:^(BOOL finished) {
        
        if(finished) {
            [self startCheckForAuthentication];
        }
    }];
}

- (void)displayLoggedInView {
    
    [UIView animateWithDuration:0.3 animations:^{
        _codeLabel.alpha = _codeAboveDescriptionLabel.alpha =
        _codeBelowDescriptionLabel.alpha = 0;
        
    } completion:^(BOOL finished) {
        if(finished) {
            _codeLabel.hidden = _codeAboveDescriptionLabel.hidden =
                _codeBelowDescriptionLabel.hidden = YES;
            
            _loggedInLabel.alpha = _loggedInImageView.alpha =
                _loggedInButton.alpha = 0;
            _loggedInLabel.hidden = _loggedInImageView.hidden =
                _loggedInButton.hidden = NO;
            
            NSString * username = [[AppConfig sharedConfig] objectForKey:kOAuthUsername];
            _loggedInLabel.text = [NSString stringWithFormat:@"Logged in as %@", username];
            
            [UIView animateWithDuration:0.3 animations:^{
                _loggedInLabel.alpha = _loggedInImageView.alpha =
                    _loggedInButton.alpha = 1;
            }];
        }
    }];
}

- (void)displayErrorAlert {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:@"Could not contact the Twitchy app server. Please try again later."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:
                      UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)startCheckForAuthentication {

    self.checkTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:
                       @selector(checkAuthentication:) userInfo:nil repeats:YES];
}

- (void)stopCheckForAuthentication {
    
    [self.checkTimer invalidate];
    self.checkTimer = nil;
}

- (void)checkAuthentication:(id)sender {
    
    [[TwitchAPIClient sharedClient] checkOAuthAuthenticationStatusWithCode:self.code completion:^(NSDictionary *result) {
        NSLog(@"AccountViewController, checkOAuthAuthenticationStatusWithCode: %@", result);
        
        // If result nil or success not present (malformed), or success == false, invalid request
        if(result == nil || ![[result allKeys] containsObject:@"success"] || [result[@"success"] intValue] == 0) {
            [self stopCheckForAuthentication];
            [self displayErrorAlert];
            return;
            
        } else if([[result allKeys] containsObject:@"authenticated"] && [result[@"authenticated"] intValue] == 1
                  && [[result allKeys] containsObject:@"token"]) {
            
            [self stopCheckForAuthentication];
            
            NSString * token = result[@"token"];
            [[AppConfig sharedConfig] setObject:token forKey:kOAuthToken];
            
            // Retrieve username for token, so we can display it in confirmation message
            [[TwitchAPIClient sharedClient] getUserDetails:^(TwitchUser *result) {
                NSLog(@"%@", result);
                
                [[AppConfig sharedConfig] setObject:result.name forKey:kOAuthUsername];
                [self displayLoggedInView];
            }];
        }
        
        // Fall-through: do nothing, user not yet authenticated
    }];
}

@end
