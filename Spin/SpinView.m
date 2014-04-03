//
//  SpinView.m
//  Spin
//
//  Copyright (c) 2012 Apportable. All rights reserved.
//

#import "SpinView.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

// For multicast DNS and DNS Service Discovery
#import <Foundation/Foundation.h>
#import <CFNetwork/CFNetwork.h>
#import <CFNetwork/CFNetServices.h>

#include <sys/socket.h>
#include <netinet/in.h>
#include <fcntl.h>
#include <unistd.h>

#import "TestmDNS.h"

#define HORIZ_SWIPE_DRAG_MIN    24
#define VERT_SWIPE_DRAG_MAX     24
#define TAP_MIN_DRAG            10

@implementation SpinView {
    EAGLContext *context;
    GLuint defaultFramebuffer, colorRenderbuffer;
    float scale;
    float rotation;
    float rotationSpeed;
    
    BOOL zoomed;
    BOOL moved;
    CGPoint startTouchPosition;
    CGFloat initialDistance;
}

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

static float spinClear = 1.f;

static const GLubyte texture1[4 * 4] =
{
    255, 128,  64, 255,
    64, 128, 255, 255,
    
    64, 128, 255, 255,
    255, 128,  64, 255,
};

static const GLubyte texture2[4 * 4] =
{
    255, 128,  64, 255,
    128, 255,  64, 255,
    
    128, 255,  64, 255,
    255, 128,  64, 255,
};

static const GLubyte colors[8 * 4] =
{
    0, 255, 0, 99,
    0, 225, 0, 255,
    0, 200, 0, 255,
    0, 175, 0, 255,
    
    0, 150, 0, 255,
    0, 125, 0, 255,
    0, 100, 0, 255,
    0, 75, 0, 255,
};

static const GLfloat vertices[8 * 3] =
{
    -1,  1,  1,
    1,  1,  1,
    1, -1,  1,
    -1, -1,  1,
    
    -1,  1, -1,
    1,  1, -1,
    1, -1, -1,
    -1, -1, -1,
};

static const GLfloat textcoords[8 * 2] =
{
    0.0f,   1.0f,
    0.0f,   0.0f,
    1.0f,   0.0f,
    1.0f,   1.0f,
    
    0.0f,   0.0f,
    1.0f,   0.0f,
    0.0f,   1.0f,
    1.0f,   1.0f,
};

static const GLubyte triangles[12 * 3] =
{
    1, 0, 3,
    1, 3, 2,
    
    2, 6, 5,
    2, 5, 1,
    
    7, 4, 5,
    7, 5, 6,
    
    0, 4, 7,
    0, 7, 3,
    
    5, 4, 0,
    5, 0, 1,
    
    3, 7, 6,
    3, 6, 2,
};

void gluPerspective(GLfloat fovy, GLfloat aspect, GLfloat zNear, GLfloat zFar)
{
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    GLfloat xmin, xmax, ymin, ymax;
    ymax = zNear * tan(fovy * M_PI / 360.0);
    ymin = -ymax;
    xmin = ymin * aspect;
    xmax = ymax * aspect;
    glFrustumf(xmin, xmax, ymin, ymax, zNear, zFar);
}


- (void)setup
{
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    
    rotation = 0.1f;
    rotationSpeed = 3.0f;
    scale = 1.0f;
    
    eaglLayer.opaque = TRUE;
    eaglLayer.drawableProperties = @{
        kEAGLDrawablePropertyRetainedBacking : @NO,
        kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8
    };
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    
    [EAGLContext setCurrentContext:context];
    
    glGenFramebuffersOES(1, &defaultFramebuffer);
    glGenRenderbuffersOES(1, &colorRenderbuffer);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, colorRenderbuffer);
    
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:eaglLayer];
    
    int width = self.frame.size.width;
    int height = self.frame.size.width;
    
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective(20, (float)width / (float) height, 5, 15);
    glViewport(0, 0, width, height);
    
    glClearColor(spinClear * .1, spinClear * .1, spinClear * .1, 1.f);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_SRC_COLOR);
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:eaglLayer];
}

- (void)render:(CADisplayLink *)link
{
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glMatrixMode(GL_MODELVIEW);
    
    glLoadIdentity();
    glTranslatef(0, 0, -10);
    glRotatef(30, 1, 0, 0);
    glScalef(scale, scale, scale);
    glRotatef(rotation, 0, 1, 0);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    
    glVertexPointer(3, GL_FLOAT, 0, vertices);
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
    
    glDrawElements(GL_TRIANGLES, 12 * 3, GL_UNSIGNED_BYTE, triangles);
    glDisableClientState(GL_COLOR_ARRAY);
    glDisableClientState(GL_VERTEX_ARRAY);
    
    rotation += rotationSpeed;
    
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
    
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
}


- (CGFloat)distanceBetweenTwoPoints:(CGPoint)fromPoint toPoint:(CGPoint)toPoint {
	float x = toPoint.x - fromPoint.x;
    float y = toPoint.y - fromPoint.y;
    NSLog(@"distanceBetweenTwoPoints: toPoint = %d %d, fromPoint = %d %d, x = %d, y = %d, sqr = %d", (int)toPoint.x, (int)toPoint.y, (int)fromPoint.x, (int)fromPoint.y, (int)x, (int)y, (int)(x*x+y*y));
    
    return sqrt(x * x + y * y);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    moved = NO;
    switch ([touches count]) {
        case 1:
        {
            // single touch
            UITouch * touch = [touches anyObject];
            startTouchPosition = [touch locationInView:self];
            initialDistance = -1;
            break;
        }
        default:
        {
            // multi touch
            NSArray *touchArray = [touches allObjects];
            NSLog(@"multi touch detected %d", [touches count]);
            UITouch *touch1 = [touchArray objectAtIndex:0];
            NSLog(@"touch1 %@", touch1);
			UITouch *touch2 = [touchArray objectAtIndex:1];
            NSLog(@"touch2 %@", touch2);
            initialDistance = [self distanceBetweenTwoPoints:[touch1 locationInView:self]
                                                     toPoint:[touch2 locationInView:self]];
            NSLog(@"Multi touch start with initial distance %d", (int)initialDistance);
            break;
        }
            
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch1 = [[touches allObjects] objectAtIndex:0];
    
    if (zoomed && ([touches count] == 1)) {
        CGPoint pos = [touch1 locationInView:self];
        self.transform = CGAffineTransformTranslate(self.transform, pos.x - startTouchPosition.x, pos.y - startTouchPosition.y);
        moved = YES;
        return;
    }
    
    if ((initialDistance > 0) && ([touches count] > 1)) {
        UITouch *touch2 = [[touches allObjects] objectAtIndex:1];
        CGFloat currentDistance = [self distanceBetweenTwoPoints:[touch1 locationInView:self]
                                                         toPoint:[touch2 locationInView:self]];
        CGFloat movement = currentDistance - initialDistance;
        NSLog(@"Touch moved: %d", (int)movement);
        if (movement != 0) {
            scale *= pow(2.0f, movement / 100);
            if (scale > 2.0) scale = 2;
            if (scale < 0.1) scale = 0.1;
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch1 = [[touches allObjects] objectAtIndex:0];
    if ([touches count] == 1) {
        if ([touch1 tapCount] > 1) {
            NSLog(@"Double tap");
            scale = 1.0f;
            rotation = 3.0f;
            return;
        }
        CGPoint currentTouchPosition = [touch1 locationInView:self];
        
        float deltaX = fabsf(startTouchPosition.x - currentTouchPosition.x);
        float deltaY = fabsf(startTouchPosition.y - currentTouchPosition.y);
        // If the swipe tracks correctly.
        if ((deltaX >= HORIZ_SWIPE_DRAG_MIN) && (deltaY <= VERT_SWIPE_DRAG_MAX))
        {
            // It appears to be a swipe.
            float movement = startTouchPosition.x - currentTouchPosition.x;
            if (movement < 0)
            {
                NSLog(@"Swipe Right");
                rotationSpeed += pow(2.0f, -movement / 100);
            }
            else
            {
                rotationSpeed -= pow(2.0f, movement / 100);
                NSLog(@"Swipe Left");
            }
        }
        else if (!moved && ((deltaX <= TAP_MIN_DRAG) && (deltaY <= TAP_MIN_DRAG)) )
        {
            // Process a tap event.
            NSLog(@"Tap");
            [self testCFNetServices:@"localhost" portNum:5353];
            NSLog(@"In touchesEnded again!");
            [TestmDNS setup];
            NSLog(@"End Tap!");
        }
    }
    else {
        // multi-touch
        UITouch *touch2 = [[touches allObjects] objectAtIndex:1];
        CGFloat finalDistance = [self distanceBetweenTwoPoints:[touch1 locationInView:self]
                                                       toPoint:[touch2 locationInView:self]];
        CGFloat movement = finalDistance - initialDistance;
        NSLog(@"Final Distance: %d, movement=%d",(int)finalDistance,(int)movement);
        if (movement != 0) {
            NSLog(@"Movement: %d", (int)movement);
        }
    }
}

#pragma mark Delegate

-(void)tellDelegate
{
    MyNetServices *service = [[MyNetServices alloc] init];
    service.delegate = self;
    [service registerMyService];
}

static void registerCallback(CFNetServiceRef theService, CFStreamError *err, void *info)
{
    NSLog(@"DAPHDAPHDAPH: %s:%d: Blah %@", __func__, __LINE__, _cfSocket);
}

-(void)startBonjour:(MyNetServices *)myService
{
    NSLog(@"DAPHDAPHDAPH: %s:%d: Blah %@", __func__, __LINE__, _cfSocket);
    CFStreamError error;

    CFStringRef serviceType = CFSTR("_nexus._udp");
    CFStringRef serviceName = CFSTR("Nexus 7 Device");
    CFStringRef domain = CFSTR("");
    int thePort = 8888;

    CFNetServiceRef netService = CFNetServiceCreate(NULL, domain, serviceType, serviceName, thePort);
    if (netService == nil)
    {
        NSLog(@"ERROR: %d: netService is nil", __LINE__);
    }

    CFNetServiceClientContext clientCtx = {0, NULL, NULL, NULL, NULL};

    CFNetServiceSetClient(netService, registerCallback, &clientCtx);
    CFNetServiceScheduleWithRunLoop(netService, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    CFOptionFlags options = 0;

    if (CFNetServiceRegisterWithOptions(netService, options, &error) == false)
    {
        CFNetServiceUnscheduleFromRunLoop(netService, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        CFNetServiceSetClient(netService, NULL, NULL);
        CFRelease(netService);
        fprintf(stderr, "Could not register Bonjour service!");
    }
}

#pragma mark Sockets

CFSocketRef _cfSocket;

static void SocketReadCallback(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info)
{
    NSLog(@"DAPHDAPHDAPH: %s:%d: Made it this far!", __func__, __LINE__);

    int err, sock;
    struct sockaddr_storage addr;
    socklen_t addrLen;
    uint8_t buf[65536];
    ssize_t bytesRead;

    sock = CFSocketGetNative(s);
    if (sock < 0) {
        err = errno;
        NSLog(@"Line %d: ERROR: errno = %d\n\n", __LINE__, err);
    }

    addrLen = sizeof(addr);
    bytesRead = recvfrom(sock, buf, sizeof(buf), 0, (struct sockaddr_storage *) &addr, &addrLen);
    if (bytesRead <= 0) {
        err = errno;
        NSLog(@"Line %d: ERROR: errno = %d\n\n", __LINE__, err);
    } else {
        NSData *dataObj;
        NSData *addrObj;

        dataObj = [NSData dataWithBytes:buf length:(NSUInteger) bytesRead];
        if (dataObj == nil) {
            err = errno;
            NSLog(@"Line %d: ERROR: errno = %d\n\n", __LINE__, err);
        }
        addrObj = [NSData dataWithBytes:&addr length:addrLen];
        if (addrObj == nil) {
            err = errno;
            NSLog(@"Line %d: ERROR: errno = %d\n\n", __LINE__, err);
        }

        NSString *msg;
        NSString *address;

        msg = [[NSString alloc]initWithData:dataObj encoding:NSUTF8StringEncoding];
        assert(msg != nil);
        //address = [[NSString alloc]initWithData:addrObj encoding:NSUTF8StringEncoding];
        //assert(address != nil);

        //NSLog(@"DAPHDAPHDAPH: Received message--\"%@\" from Client %@", msg, address);
        NSLog(@"DAPHDAPHDAPH: Received message--\"%@\" from Client", msg);
        [msg release];
        //[address release];
    }
}

- (void)testCFNetServices:(NSString *)host portNum:(NSUInteger)port
{
    NSLog(@"Huzzah! Calling testCFNetServices! addr=%@:%d", host, port);

    sa_family_t socketFamily;
    int err, junk, sock;
    CFRunLoopSourceRef rls;

    const CFSocketContext context = {0, (__bridge void *) (self), NULL, NULL, NULL};

    NSLog(@"Moving onto creating the udp socket!");
    // Create UDP socket for IPv6 (default) or IPv4
    err = 0;
    sock = socket(AF_INET6, SOCK_DGRAM, 0);
    if (sock >= 0) {
        socketFamily = AF_INET6;
        NSLog(@"DAPHDAPHDAPH: %d: socketFamily is ipv6", __LINE__);
    } else {
        sock = socket(AF_INET, SOCK_DGRAM, 0);
        if (sock >= 0) {
            socketFamily = AF_INET;
            NSLog(@"DAPHDAPHDAPH: %d: socketFamily is ipv4", __LINE__);
        } else {
            err = errno;
            socketFamily = 0;
            NSLog(@"Line %d: ERROR: errno = %d", __LINE__, err);
        }
    }

    // Bind the socket
    if (err == 0) {
        struct sockaddr_storage addr;
        struct sockaddr_in * addr4;
        struct sockaddr_in6 * addr6;

        addr4 = (struct sockaddr_in *) &addr;
        addr6 = (struct sockaddr_in6 *) &addr;
        
        memset(&addr, 0, sizeof(addr));
        addr.ss_family = socketFamily;
        if (socketFamily == AF_INET) {
            addr4->sin_len = sizeof(*addr4);
            addr4->sin_port = htons(port);
            addr4->sin_addr.s_addr = INADDR_ANY;
        } else {
            addr6->sin6_port = htons(port);
            addr6->sin6_addr = in6addr_any;
        }

        NSLog(@"LINE %d: Binding the socket", __LINE__);
        err = bind(sock, (const struct sockaddr *) &addr, sizeof(*addr6));
        if (err < 0) {
            err = errno;
            NSLog(@"Line %d: ERROR: errno = %d\n\n", __LINE__, err);
        }
    }

    // Make socket non-blocking
    if (err == 0) {
        NSLog(@"LINE %d: Making socket non-blocking", __LINE__);
        int flags;

        flags = fcntl(sock, F_GETFL);
        err = fcntl(sock, F_SETFL, flags | O_NONBLOCK);
        if (err < 0) {
            err = errno;
            NSLog(@"Line %d: ERROR: errno = %d\n\n", __LINE__, err);
        }
    }

    // Wrap socket in CFSocket
    if (err == 0) {
        NSLog(@"LINE %d: Wrapping socket in CFSocket", __LINE__);
        _cfSocket = CFSocketCreateWithNative(NULL, sock, kCFSocketReadCallBack, SocketReadCallback, &context);

        assert(CFSocketGetSocketFlags(_cfSocket) & kCFSocketCloseOnInvalidate);
        sock = -1;

        rls = CFSocketCreateRunLoopSource(NULL, _cfSocket, 0);
        if (rls == NULL) {
            err = errno;
            NSLog(@"Line %d: ERROR: errno = %d\n\n", __LINE__, err);
        }

        CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, kCFRunLoopDefaultMode);

        CFRelease(rls);
        // Add shit to make server read data being passed to it and responds
        //     - See UDPEcho.m
        //          215: SocketReadCallback
        //          162: readData
    }

    if (sock != -1) {
        junk = close(sock);
        if (junk != 0) {
            err = errno;
            NSLog(@"Line %d: ERROR: errno = %d\n\n", __LINE__, err);
        }
    }

    if (err != 0) {
        NSLog(@"Line %d: ERROR: errno = %d\n\n", __LINE__, err);
    }

    // Tell the delegate UDP server is up
    [self tellDelegate];

}

@end
