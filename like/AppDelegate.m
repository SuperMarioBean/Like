//
//  AppDelegate.m
//  like
//
//  Created by David Fu on 5/21/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate+EaseMob.h"

#import <SMS_SDK/SMS_SDK.h>

#ifndef DEBUG
#import <FIR/FIR.h>
#endif

@interface AppDelegate () {
    BOOL _lastTutorialFlag;
}

@property (readwrite, nonatomic, strong) UIViewController *rootViewController;

@end

@implementation AppDelegate

#pragma mark - life cycle

#pragma mark - delegate methods

#pragma mark UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
#ifndef DEBUG
    [FIR handleCrashWithKey:@"c360dd80066422b3e11b86d45b55d2fe"];
#endif
    
    self.window.tintColor = [UIColor like_tintColor];
    
    [SMS_SDK registerApp:@"812383acc169" withSecret:@"72e728e8b96ade2ce52f7b4e387fcf57"];
    [self easemobApplication:application didFinishLaunchingWithOptions:launchOptions];
    [[LIKELocationManager sharedInstance] startForceLocating];
    
    // MAKR: 减少并发下载数量
    [SDWebImageDownloader sharedDownloader].maxConcurrentDownloads = 2;
    
    self.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
    // 暂时默认动画为渐变, 后期需要定制
    self.rootViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    self.window.rootViewController = self.rootViewController;
    
    [LIKELocationManager sharedInstance];
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

#pragma mark - event response

#pragma mark - private methods

#pragma mark - accessor methods

#pragma mark - api methods



@end
