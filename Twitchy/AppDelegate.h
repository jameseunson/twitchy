//
//  AppDelegate.h
//  Twitchy
//
//  Created by James Eunson on 1/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// User is no longer logged in, replace following controller with login controller
- (void)revertLogin;

// User has transitioned from not logged in -> logged in state, replace login controller
// with authenticated user controller
- (void)continueToAuthenticatedController;

@end

