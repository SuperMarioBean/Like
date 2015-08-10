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

@interface AppDelegate () <ICETutorialControllerDelegate> {
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
    
    // MAKR: 减少并发下载数量
    [SDWebImageDownloader sharedDownloader].maxConcurrentDownloads = 2;
    
    self.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
    // 暂时默认动画为渐变, 后期需要定制
    self.rootViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    // APP 第一次开启, 设置最初的欢迎页面
    // 始终为第一次打开应用
    [LIKEAppContext sharedInstance].hasWelcomeNewUser = NO;
    if (![LIKEAppContext sharedInstance].hasWelcomeNewUser) {
        self.window.rootViewController = [self setupTutorialViewController];
        
    }
    else {
        self.window.rootViewController = self.rootViewController;
    }
    
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

#pragma mark ICETutorialControllerDelegate

- (void)tutorialController:(ICETutorialController *)tutorialController scrollingFromPageIndex:(NSUInteger)fromIndex toPageIndex:(NSUInteger)toIndex {
    
}

- (void)tutorialControllerDidReachLastPage:(ICETutorialController *)tutorialController {
    [[LIKEAppContext sharedInstance] setHasWelcomeNewUser:YES];
    _lastTutorialFlag = YES;
}

// 暂时对这一侧的两个按钮都做事件处理, 后面需要定制这个行为并设置相应的动画
- (void)tutorialController:(ICETutorialController *)tutorialController didClickOnLeftButton:(UIButton *)sender {
    if (_lastTutorialFlag) {
        [self.window.rootViewController presentViewController:self.rootViewController animated:YES completion:^{
            
        }];
    }
}

- (void)tutorialController:(ICETutorialController *)tutorialController didClickOnRightButton:(UIButton *)sender {
    if (_lastTutorialFlag) {
        [self.window.rootViewController presentViewController:self.rootViewController animated:YES completion:^{
            
        }];
    }
}

#pragma mark - event response

#pragma mark - private methods

- (UIViewController *)setupTutorialViewController {
    // Init the pages texts, and pictures.
    ICETutorialPage *layer1 = [[ICETutorialPage alloc] initWithTitle:@"Picture 1"
                                                            subTitle:@"Champs-Elysées by night"
                                                         pictureName:@"tutorial_background_00@2x.jpg"
                                                            duration:3.0];
    ICETutorialPage *layer2 = [[ICETutorialPage alloc] initWithTitle:@"Picture 2"
                                                            subTitle:@"The Eiffel Tower with\n cloudy weather"
                                                         pictureName:@"tutorial_background_01@2x.jpg"
                                                            duration:3.0];
    ICETutorialPage *layer3 = [[ICETutorialPage alloc] initWithTitle:@"Picture 3"
                                                            subTitle:@"An other famous street of Paris"
                                                         pictureName:@"tutorial_background_02@2x.jpg"
                                                            duration:3.0];
    ICETutorialPage *layer4 = [[ICETutorialPage alloc] initWithTitle:@"Picture 4"
                                                            subTitle:@"The Eiffel Tower with a better weather"
                                                         pictureName:@"tutorial_background_03@2x.jpg"
                                                            duration:3.0];
    ICETutorialPage *layer5 = [[ICETutorialPage alloc] initWithTitle:@"Picture 5"
                                                            subTitle:@"The Louvre's Museum Pyramide"
                                                         pictureName:@"tutorial_background_04@2x.jpg"
                                                            duration:3.0];
    NSArray *tutorialLayers = @[layer1,layer2,layer3,layer4,layer5];
    
    // Set the common style for the title.
    ICETutorialLabelStyle *titleStyle = [[ICETutorialLabelStyle alloc] init];
    [titleStyle setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17.0f]];
    [titleStyle setTextColor:[UIColor whiteColor]];
    [titleStyle setLinesNumber:1];
    [titleStyle setOffset:180];
    [[ICETutorialStyle sharedInstance] setTitleStyle:titleStyle];
    
    // Set the subTitles style with few properties and let the others by default.
    [[ICETutorialStyle sharedInstance] setSubTitleColor:[UIColor whiteColor]];
    [[ICETutorialStyle sharedInstance] setSubTitleOffset:150];
    
    // Init tutorial.
    ICETutorialController *viewController = [[ICETutorialController alloc] initWithPages:tutorialLayers
                                                                                delegate:self];
    // Run it.
    [viewController startScrolling];
    
    return viewController;
}

#pragma mark - accessor methods

#pragma mark - api methods



@end
