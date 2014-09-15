///
//  AppDelegate.m
//  kinectClient
//
//  Created by 陈标 on 14-4-19.
//  Copyright (c) 2014年 Cb. All rights reserved.
//

#import "AppDelegate.h"
#import "menuViewController.h"
#import "mainViewController.h"
#import "remoteControlViewController.h"
#import "ICSDrawerController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    NSArray *menuList = [NSArray arrayWithObjects:@"Data Stream",@"Remote Control", nil];
    NSArray *colors = @[[UIColor colorWithRed:237.0f/255.0f green:195.0f/255.0f blue:0.0f/255.0f alpha:1.0f],
                        [UIColor colorWithRed:237.0f/255.0f green:147.0f/255.0f blue:0.0f/255.0f alpha:1.0f]
                        ];
    //初始化menuViewController
    menuViewController *left = [[menuViewController alloc]initWithMenus:menuList andColors:colors];
    //初始化mainviewcontroller为Storybroad中的mainCenterViewController
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
    mainViewController *center = (mainViewController *)[storyboard instantiateInitialViewController];
    
    //初始化drawer
    ICSDrawerController *drawer = [[ICSDrawerController alloc]initWithLeftViewController:left centerViewController:center];
    //加载到rootViewontroller
    self.window.rootViewController = drawer;

    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
