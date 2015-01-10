//
//  AppDelegate.m
//  SpecViewT1
//
//  Created by riskej & trefi, 2015.
//  Copyright (c) 2015 SimbolBit. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <DropboxSDK/DropboxSDK.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize window, IncomingURL;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    DBSession *dbSession = [[DBSession alloc]
                            initWithAppKey:@"6ta68odfvpkhxe2"
                            appSecret:@"9tcjf8c6r7yx14g"
                            root:kDBRootAppFolder]; // either kDBRootAppFolder or kDBRootDropbox
    [DBSession setSharedSession:dbSession];
    
    return YES;
    
}


-(BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    //    ViewController *_ViewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    //    ViewController *_ViewController;
    
    if (url != nil && [url isFileURL]) {
        IncomingURL = url;
        //        _ViewController.currentData = [NSData dataWithContentsOfURL:url];
        //        [_ViewController convert6912Screen];
    }
    
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            NSLog(@"App linked successfully!");
            // At this point you can start making API calls
        }
        return YES;
    }
    // Add whatever other url handling code your app requires here
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
    
    //    NSLog(@"App did become active!");
    
    NSLog(@"Incoming URL: %@", IncomingURL);
    
    //    ViewController *_ViewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    //    _ViewController.currentData = [NSData dataWithContentsOfURL:IncomingURL];
    //    [_ViewController.navigationController pushViewController:_ViewController animated:YES];
    //    [_ViewController.navigationController setViewControllers:@[_ViewController] animated:YES];
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
