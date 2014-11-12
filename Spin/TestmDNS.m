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

    return @YES;
}

+(id)test_udp
{
    //const char *name = "test_device";
    //const char *type = "_http._udp";
    //const char *domain = "local.";
    //uint16_t port = 8888;

    //[self registerService:name regType:type theDomain:domain theHost:NULL thePort:port];

    [self testNsdManager];

    return YES;
}

+ (void)testNsdManager
{
    NSLog(@"DAPHDAPHDAPHDAPH: %s: %d", __func__, __LINE__);
    BK2AndroidNsdManager *mgr = (BK2AndroidNsdManager *)[[BK2AndroidActivity currentActivity] nsdManager];
    [mgr discoverServices:@"_http._tcp"];

    [mgr registerService:@"TestmDns" serviceType:@"_http._tcp" servicePort:8889];

    //NSLog(@"DAPHDAPHDAPHDAPHDAPH: HAHA. MADE IT THIS FAR: %s: %d", __func__, __LINE__);
    //[mgr stopServiceDiscovery];
    NSLog(@"DAPHDAPHDAPHDAPH: %s: %d", __func__, __LINE__);
}

+(void)registerService:(const char *)name regType:(const char *)type theDomain:(const char *)domain theHost:(const char *)host thePort:(uint16_t)port
{
    NSLog(@"DAPHDAPHDAPHDAPH: %s:%d", __func__, __LINE__);
    DNSServiceErrorType err;
    DNSServiceRef sdRef;

    const char *txtrec = "\011txtvers=1\020path=/index.html\025note=Bonjour Is Cool!";

    err = DNSServiceRegister(&sdRef, 0, 0, name, type, domain, host, port, (uint16_t) strlen(txtrec), (const void *)txtrec, NULL, NULL);
    if (err)
    {
        NSLog(@"ERROR: %s:%d: err = %d", __func__, __LINE__, err);
    }
}

@end
