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

@implementation SpinView {
    EAGLContext *context;
    GLuint defaultFramebuffer, colorRenderbuffer;
    float scale;
    float rotation;
    float rotationSpeed;
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

@end
