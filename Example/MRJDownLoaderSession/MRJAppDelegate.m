//
//  MRJAppDelegate.m
//  MRJDownLoaderSession
//
//  Created by mrjlovetian@gmail.com on 07/18/2018.
//  Copyright (c) 2018 mrjlovetian@gmail.com. All rights reserved.
//

#import "MRJAppDelegate.h"

@implementation MRJAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
//    http://www.dehyc.com/upload/mp3/%E5%B0%91%E5%A6%87%E7%99%BD%E6%B4%81/%E5%B0%91%E5%A6%87%E7%99%BD%E6%B4%81034%E5%BC%A0%E6%95%8F%E7%AF%87.mp3
//    http://www.dehyc.com/upload/mp3/%E5%B0%91%E5%A6%87%E7%99%BD%E6%B4%81/%E5%B0%91%E5%A6%87%E7%99%BD%E6%B4%81027%E5%BC%A0%E6%95%8F%E7%AF%87.mp3
//    http://www.dehyc.com/upload/mp3/%E5%B0%91%E5%A6%87%E7%99%BD%E6%B4%81/%E5%B0%91%E5%A6%87%E7%99%BD%E6%B4%81038%E9%A3%8E%E6%83%85%E4%B8%87%E7%A7%8D.mp3
//    http://www.dehyc.com/upload/mp3/%E5%B0%91%E5%A6%87%E7%99%BD%E6%B4%81/%E5%B0%91%E5%A6%87%E7%99%BD%E6%B4%81034%E5%BC%A0%E6%95%8F%E7%AF%87.mp3
//    http://www.dehyc.com/upload/mp3/%E5%B0%91%E5%A6%87%E7%99%BD%E6%B4%81/%E5%B0%91%E5%A6%87%E7%99%BD%E6%B4%81%E7%B3%BB%E5%88%97%E4%B9%8B%E6%B7%AB%E4%B9%B1%E7%9A%84%E7%94%9F%E6%97%A5%E6%99%9A%E4%BC%9A02.mp3
    NSString *str = @"http://www.dehyc.com/upload/mp3/%E5%B0%91%E5%A6%87%E7%99%BD%E6%B4%81/%E5%B0%91%E5%A6%87%E7%99%BD%E6%B4%81027%E5%BC%A0%E6%95%8F%E7%AF%";
    for (int i = 87; i < 103; i++) {
        NSLog(@"%@%d.mp3", str, i);
    }
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
