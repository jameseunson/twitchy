//
//  AccountViewController.h
//  Twitchy
//
//  Created by James Eunson on 3/05/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIButton * loginButton;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView * loadingView;

@property (nonatomic, strong) IBOutlet UILabel * codeAboveDescriptionLabel;
@property (nonatomic, strong) IBOutlet UILabel * codeBelowDescriptionLabel;
@property (nonatomic, strong) IBOutlet UILabel * codeLabel;

@property (nonatomic, strong) IBOutlet UIImageView * loggedInImageView;
@property (nonatomic, strong) IBOutlet UILabel * loggedInLabel;
@property (nonatomic, strong) IBOutlet UIButton * loggedInButton;

@end
