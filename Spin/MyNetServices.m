//
//  MyNetServices.m
//  Spin
//
//  Created by Daphne Larose on 4/1/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "MyNetServices.h"

@implementation MyNetServices

/*-(void)registerMyService
{
    [_delegate startBonjour:self];
}*/

-(void)dealloc
{
    [super dealloc];
    _delegate = nil;
}

@end
