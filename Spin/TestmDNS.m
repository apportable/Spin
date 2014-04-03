//
//  TestmDNS.m
//  Spin
//
//  Created by Daphne Larose on 4/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "TestmDNS.h"

@implementation TestmDNS

+(void)setup
{
    [self test_udp];
}

+(id)test_tcp
{
    const char *name = "test_device";
    const char *type = "_http._tcp";
    const char *domain = "local.";
    uint16_t port = 8888;

    [self registerService:name regType:type theDomain:domain theHost:nil thePort:port];

    return YES;
}

+(id)test_udp
{
    const char *name = "test_device";
    const char *type = "_http._udp";
    const char *domain = "local.";
    uint16_t port = 8888;

    [self registerService:name regType:type theDomain:domain theHost:nil thePort:port];

    return YES;
}

+(void)registerService:(const char *)name regType:(const char *)type theDomain:(const char *)domain theHost:(const char *)host thePort:(uint16_t)port
{
    NSLog(@"DAPHDAPHDAPHDAPH: %s:%d", __func__, __LINE__);
    DNSServiceErrorType err;
    DNSServiceRef sdRef;

    err = DNSServiceRegister(&sdRef, 0, 0, name, type, domain, host, port, 0, NULL, NULL, NULL);
    if (err)
    {
        NSLog(@"ERROR: %s:%d: err = %d", __func__, __LINE__, err);
    }
}

@end
