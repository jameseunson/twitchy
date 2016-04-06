//
//  AppDelegate.m
//  Twitchy
//
//  Created by James Eunson on 1/04/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "AppDelegate.h"
#import "SearchResultsViewController.h"
#import "SearchViewController.h"

@interface AppDelegate ()

@property (nonatomic, strong) SearchResultsViewController* searchResultsViewController;
@property (nonatomic, strong) SearchViewController * searchViewController;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName: @"Main" bundle:[NSBundle mainBundle]];
    self.searchResultsViewController = [storyboard instantiateViewControllerWithIdentifier:@"SearchResultsViewController"];
    
    UISearchController * searchController = [[UISearchController alloc] initWithSearchResultsController:_searchResultsViewController];
    UISearchContainerViewController * containerController = [[UISearchContainerViewController alloc] initWithSearchController:searchController];
    
    UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:containerController];
    navController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Search" image:nil tag:0];
    
    UITabBarController * tabBarController = (UITabBarController*)self.window.rootViewController;
    
    NSMutableArray * controllers = [tabBarController.viewControllers mutableCopy];
    [controllers addObject:navController];
    
    self.searchViewController = [[SearchViewController alloc] init];
    searchController.searchResultsUpdater = _searchViewController;
    
    [tabBarController setViewControllers:controllers];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
