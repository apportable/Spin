//
//  SpinAppDelegate.m
//
//  Copyright (c) 2012 Apportable. All rights reserved.
//

#import "SpinAppDelegate.h"
#import "SpinViewController.h"
#import <Parse/Parse.h>


@implementation SpinAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"application: %@ didFinishLaunchingWithOptions: %@ state: %d", application, launchOptions, [[UIApplication sharedApplication] applicationState]);
    
#ifdef APPORTABLE
	[[UIScreen mainScreen] setCurrentMode:[UIScreenMode emulatedMode:UIScreenBestEmulatedMode]];
#endif
    
    [Parse setApplicationId:@"PLEASE ALSO: set your applicationId in configuration.json"
                  clientKey:@"PLEASE ALSO: set your clientKey in configuration.json"];
#ifdef APPORTABLE
    // N.B.: Requires compiling against Apportable-modified headers.  This may be moved to an internal header in future SDK revisions.  Useful for debugging on Android...
    [Parse setLogLevel:PARSE_LOG_LEVEL_VERBOSE];
#endif
    
    // Register for push notifications
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound];
    
    // Launched from a push notification?
    NSDictionary *payload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (payload)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self application:application didReceiveRemoteNotification:payload];
        });
    }

    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.viewController = [[[SpinViewController alloc] initWithNibName:@"SpinViewController" bundle:nil] autorelease];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    [[PFInstallation currentInstallation] setDeviceTokenFromData:newDeviceToken];
    [[PFInstallation currentInstallation] saveInBackground];

    [PFPush storeDeviceToken:newDeviceToken];
    [PFPush subscribeToChannelInBackground:@""]; // global broadcast channel
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code == 3010) {
        NSLog(@"Push notifications are not supported in the iOS Simulator.");
    } else {
        // show some alert or otherwise handle the failure to register.
        NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"applicationWillResignActive: %@ state: %d", application, [[UIApplication sharedApplication] applicationState]);
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"applicationDidEnterBackground: %@ state: %d", application, [[UIApplication sharedApplication] applicationState]);
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"applicationWillEnterForeground: %@ state: %d", application, [[UIApplication sharedApplication] applicationState]);
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"applicationDidBecomeActive: %@ state: %d", application,[[UIApplication sharedApplication] applicationState]);
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"applicationWillTerminate: %@ state: %d", application, [[UIApplication sharedApplication] applicationState]);
}

@end
