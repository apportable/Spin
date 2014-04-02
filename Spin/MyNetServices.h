//
//  MyNetServices.h
//  Spin
//
//  Created by Daphne Larose on 4/1/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MyNetServices;

@protocol MyNetServicesDelegate

-(void)startBonjour:(MyNetServices *)myService;

@end


@interface MyNetServices : NSObject

@property (nonatomic, assign) id delegate;

-(void)registerMyService;

@end
