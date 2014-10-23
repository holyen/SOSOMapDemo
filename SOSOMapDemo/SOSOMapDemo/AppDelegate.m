//
//  AppDelegate.m
//  SOSOMapDemo
//
//  Created by holyenzou on 14/10/23.
//  Copyright (c) 2014年 holyenzou. All rights reserved.
//

#import "AppDelegate.h"
#import <mach/mach_time.h>


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    QAppKeyCheck *check = [[QAppKeyCheck alloc] init];
    [check start:@"WVLBZ-SMD3F-WVNJJ-JC242-5JIKE-FKF72" withDelegate:self];
    self.appKeyCheck = check;

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.mainViewController = [[MainViewController alloc] initWithNibName:nil bundle:nil];
    self.window.rootViewController = self.mainViewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)notifyAppKeyCheckResult:(QErrorCode)errCode
{
    NSLog(@"errcode = %lu",(unsigned long)errCode);
    
    if (errCode == QErrorNone) {
        NSLog(@"恭喜您，APPKey验证通过！");
    } else if(errCode == QNetError) {
        NSLog(@"网络好像不太给力耶！请检查下网络是否畅通?");
    } else if(errCode == QAppKeyCheckFail) {
        NSLog(@"您的APPKEY好像是有问题喔，请检查下APPKEY是否正确？");
    }
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
