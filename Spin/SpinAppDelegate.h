//
//  SpinAppDelegate.h
//  Spin
//
//  Copyright (c) 2012 Apportable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameController/GameController.h>

@class SpinViewController;

@interface SpinAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) SpinViewController *viewController;

@property(strong, nonatomic) NSArray *controllerArray;

@property(strong, nonatomic) GCController *myController;

@end
