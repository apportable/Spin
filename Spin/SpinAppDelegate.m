//
//  SpinAppDelegate.m
//
//  Copyright (c) 2012 Apportable. All rights reserved.
//

#import "SpinAppDelegate.h"

#import "SpinViewController.h"

#import "HelloBridge.h"

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
    HelloBridge *bridgeObject = [[HelloBridge alloc] initWithIntValue:42 doubleValue:55.4];
    NSLog(@"%d %f", bridgeObject.intValue, [bridgeObject doubleValue]);

    [bridgeObject setIntValue:99];
    [bridgeObject setDoubleValue:11.44];
    
    NSLog(@"%d %f", bridgeObject.intValue, [bridgeObject doubleValue]);

    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.viewController = [[[SpinViewController alloc] initWithNibName:@"SpinViewController" bundle:nil] autorelease];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
