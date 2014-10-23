//
//  AppDelegate.h
//  SOSOMapDemo
//
//  Created by holyenzou on 14/10/23.
//  Copyright (c) 2014年 holyenzou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QAppKeyCheck.h"
#import "MainViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, QAppKeyCheckDelegate>

@property (nonatomic, strong) QAppKeyCheck *appKeyCheck;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MainViewController *mainViewController;


@end

