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

@end
