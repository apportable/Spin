//
//  SpinAppDelegate.m
//
//  Copyright (c) 2012 Apportable. All rights reserved.
//

#import "SpinAppDelegate.h"

#import "SpinViewController.h"


@implementation SpinAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize controllerArray = _controllerArray;
@synthesize myController = _myController;

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [_controllerArray release];
    [super dealloc];
}

- (void)setupControllers:(NSNotification *)notification
{
    // Get Controllers
    self.controllerArray = [GCController controllers];
    if (self.controllerArray) {
        NSLog(@"Array of controllers is not nil.");
    }
    else {
        NSLog(@"Array of controllers is nil!");
    }
    int controllers_count = [[GCController controllers] count];
    if (controllers_count == 0)
    {
        NSLog(@"no controllers connected....this shouldnt happen.");
    }
    for (int i = 0; i < controllers_count; ++i)
    {
        self.myController = [GCController controllers][i];

        GCExtendedGamepad *profile = self.myController.extendedGamepad;
        if (profile) {
            NSLog(@"profile found, setting up handler");

            //Two different styles of registering callbacks, both are valid
//            profile.buttonA.valueChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed)
//            {
//                if (pressed)
//                {
//                    NSLog(@"A button pressed");
//                }
//            };
//            profile.leftShoulder.valueChangedHandler =^(GCControllerButtonInput *button, float value, BOOL pressed)
//            {
//                NSLog(@"left shoulder changed");
//                if (pressed)
//                {
//                    NSLog(@"left shoulder bumped");
//                }
//            };
            
            profile.valueChangedHandler = ^(GCExtendedGamepad *gamepad, GCControllerElement *element)
            {
                if (gamepad.rightTrigger == element && gamepad.rightTrigger.isPressed)
                {
                    NSLog(@"right trigger pulled!");
                }
                if (gamepad.leftTrigger == element && gamepad.leftTrigger.isPressed)
                {
                    NSLog(@"left trigger pulled!");
                }
                if (gamepad.leftShoulder == element && gamepad.leftShoulder.isPressed)
                {
                    NSLog(@"Left shoulder bumped");
                }
                if (gamepad.rightShoulder == element && gamepad.rightShoulder.isPressed)
                {
                    NSLog(@"right shoulder bumped");
                }
                if (gamepad.buttonA == element && gamepad.buttonA.isPressed)
                {
                    NSLog(@"A Button Pressed");
                }
                if (gamepad.buttonB == element && gamepad.buttonB.isPressed)
                {
                    NSLog(@"B Button Pressed");
                }
                if (gamepad.buttonX == element && gamepad.buttonX.isPressed)
                {
                    NSLog(@"X Button Pressed");
                }
                if (gamepad.buttonY == element && gamepad.buttonY.isPressed)
                {
                    NSLog(@"WHYYYY Button Pressed");
                }
                
                if (gamepad.dpad.down == element && gamepad.dpad.down.isPressed)
                {
                    NSLog(@"Directional Pad pressed down!");
                }
                if (gamepad.dpad.up == element && gamepad.dpad.up.isPressed)
                {
                    NSLog(@"Directional Pad pressed up!");
                }
                if (gamepad.dpad.left == element && gamepad.dpad.left.isPressed)
                {
                    NSLog(@"Directional Pad pressed left!");
                }
                if (gamepad.dpad.right == element && gamepad.dpad.right.isPressed)
                {
                    NSLog(@"Directional Pad pressed right!");
                }
                if (gamepad.leftThumbstick.xAxis == element || gamepad.leftThumbstick.yAxis == element)
                {
                    NSLog(@"Left thumbstick x:%f, y:%f", gamepad.leftThumbstick.xAxis.value, gamepad.leftThumbstick.yAxis.value);
                }
                if (gamepad.rightThumbstick.xAxis == element || gamepad.rightThumbstick.yAxis == element)
                {
                    NSLog(@"Right thumbstick x:%f, y:%f", gamepad.rightThumbstick.xAxis.value, gamepad.rightThumbstick.yAxis.value);
                }

            };
        }
    }
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"application: %@ didFinishLaunchingWithOptions: %@ state: %d", application, launchOptions, [[UIApplication sharedApplication] applicationState]);
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.viewController = [[[SpinViewController alloc] initWithNibName:@"SpinViewController" bundle:nil] autorelease];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    [self setupControllers:nil];//call in case controller is already connected
    
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    // Set up connect notification
    [center addObserver:self selector:@selector(setupControllers:)
                    name:GCControllerDidConnectNotification object:nil];
    
    [GCController startWirelessControllerDiscoveryWithCompletionHandler:^(void){
        NSLog(@"GCController startWirelessControllerDiscoveryWithCompletionHandler done\n");
    }];
    
    return YES;
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
