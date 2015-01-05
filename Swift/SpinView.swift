//
//  SpinView.swift
//  Spin
//
//  Created by Paul Beusterien on 12/18/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

import UIKit

@objc(SpinView)
class SpinView : UIView {
    var context : EAGLContext?
    var defaultFramebuffer : GLuint = 0
    var colorRenderbuffer : GLuint = 0
    var scale : Float = 0
    var rotation : Float = 0
    var rotationSpeed : Float = 0
    var zoomed : Bool = false
    var moved : Bool = false
    var startTouchPosition = CGPoint(x:0, y:0)
    var initialDistance : Float = 0.0
    let spinClear : Float = 1.0
    let HORIZ_SWIPE_DRAG_MIN : Float = 24.0
    let VERT_SWIPE_DRAG_MAX : Float = 24.0
    let TAP_MIN_DRAG : Float = 10.0
    
    let colors : [UInt8] = [
        0, 255, 0, 99,
        0, 225, 0, 255,
        0, 200, 0, 255,
        0, 175, 0, 255,
        
        0, 150, 0, 255,
        0, 125, 0, 255,
        0, 100, 0, 255,
        0, 75, 0, 255,
    ]
    
    let vertices : [GLfloat] = [
        -1,  1,  1,
        1,  1,  1,
        1, -1,  1,
        -1, -1,  1,
        
        -1,  1, -1,
        1,  1, -1,
        1, -1, -1,
        -1, -1, -1,
    ]
    
    let triangles : [GLubyte] = [
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
    ]
    
    override class func layerClass() -> AnyClass {
        return CAEAGLLayer.self
    }
    
    func gluPerspective(fovy : GLfloat, aspect : GLfloat, zNear : GLfloat, zFar : GLfloat)
    {
        glMatrixMode(GLenum(GL_PROJECTION));
        glLoadIdentity();
        let tanresult = tan(Double(fovy) * M_PI / 360.0)
        let ymax = zNear * GLfloat(tanresult)
        let ymin : GLfloat  = -ymax
        let xmin : GLfloat  = ymin * aspect
        let xmax : GLfloat  = ymax * aspect
        glFrustumf(xmin, xmax, ymin, ymax, zNear, zFar);
    }
    
    func setup()
    {
        let eaglLayer : CAEAGLLayer = self.layer as CAEAGLLayer
        
        rotation = 0.1;
        rotationSpeed = 3.0;
        scale = 1.0;
        
        eaglLayer.opaque = true;
        eaglLayer.drawableProperties = [
            kEAGLDrawablePropertyRetainedBacking : false,
            kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8
        ] as NSDictionary
        context = EAGLContext(API:EAGLRenderingAPI.OpenGLES1)
        
        EAGLContext.setCurrentContext(context);
        
        glGenFramebuffersOES(1, &defaultFramebuffer);
        glGenRenderbuffersOES(1, &colorRenderbuffer);
        
        glBindFramebufferOES(GLenum(GL_FRAMEBUFFER_OES), defaultFramebuffer);
        glBindRenderbufferOES(GLenum(GL_RENDERBUFFER_OES), colorRenderbuffer);
        glFramebufferRenderbufferOES(GLenum(GL_FRAMEBUFFER_OES), GLenum(GL_COLOR_ATTACHMENT0_OES), GLenum(GL_RENDERBUFFER_OES), colorRenderbuffer);

        self.context!.renderbufferStorage(Int(GL_RENDERBUFFER_OES), fromDrawable:eaglLayer);
        
        let width = self.frame.size.width;
        let height = self.frame.size.width;
        
        glEnable(GLenum(GL_DEPTH_TEST));
        glEnable(GLenum(GL_CULL_FACE));
        
        glMatrixMode(GLenum(GL_PROJECTION));
        glLoadIdentity();
        gluPerspective(20, aspect: Float(width / height), zNear: 5, zFar: 15);
        glViewport(0, 0, GLsizei(width), GLsizei(height));
        
        glClearColor(spinClear * 0.1, spinClear * 0.1, spinClear * 0.1, 1.0);
        
        glEnable(GLenum(GL_BLEND));
        glBlendFunc(GLenum(GL_ONE), GLenum(GL_SRC_COLOR));
    }
    
    required init (coder : NSCoder)
    {
        super.init(coder: coder)
        self.setup()
    }
    override init (frame : CGRect)
    {
        super.init(frame: frame)
        self.setup()
    }
    
    func setBounds(bounds : CGRect)
    {
        super.bounds = bounds;
        let eaglLayer : CAEAGLLayer = self.layer as CAEAGLLayer
        self.context?.renderbufferStorage(Int(GL_RENDERBUFFER_OES), fromDrawable:eaglLayer)
    }
    
    func render(link : CADisplayLink)
    {
        glBindFramebufferOES(GLenum(GL_FRAMEBUFFER_OES), GLenum(defaultFramebuffer));
        
        glClear(GLenum(UInt(GL_COLOR_BUFFER_BIT) | UInt(GL_DEPTH_BUFFER_BIT)));
        
        glMatrixMode(GLenum(GL_MODELVIEW));
        
        glLoadIdentity();
        glTranslatef(0, 0, -10);
        glRotatef(30, 1, 0, 0);
        glScalef(scale, scale, scale);
        glRotatef(rotation, 0, 1, 0);
        
        glEnableClientState(GLenum(GL_VERTEX_ARRAY));
        glEnableClientState(GLenum(GL_COLOR_ARRAY));
        
        glVertexPointer(3, GLenum(GL_FLOAT), 0, vertices);
        glColorPointer(4, GLenum(GL_UNSIGNED_BYTE), 0, colors);
        
        glDrawElements(GLenum(GL_TRIANGLES), 12 * 3, GLenum(GL_UNSIGNED_BYTE), triangles);
        glDisableClientState(GLenum(GL_COLOR_ARRAY));
        glDisableClientState(GLenum(GL_VERTEX_ARRAY));
        
        rotation += rotationSpeed;
        
        glBindRenderbufferOES(GLenum(GL_RENDERBUFFER_OES), colorRenderbuffer);
        
        self.context?.presentRenderbuffer(Int(GL_RENDERBUFFER_OES))
    }
    
    func distanceBetweenTwoPoints(fromPoint : CGPoint, toPoint : CGPoint) -> Float
    {
        let x : Float = Float(toPoint.x) - Float(fromPoint.x)
        let y : Float = Float(toPoint.y) - Float(fromPoint.y)
        println("distanceBetweenTwoPoints: toPoint = \(Int(toPoint.x)) \(Int(toPoint.y)), fromPoint = \(Int(fromPoint.x)) \(Int(fromPoint.y)), x = \(Int(x)), y = \(Int(y)), sqr = \(Int(x*x + y*y))")
        return sqrtf(Float(x * x) + Float(y * y))
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        moved = false
        switch (touches.count) {
        case 1:
            let touch = touches.anyObject() as UITouch
            startTouchPosition = touch.locationInView(self)
            initialDistance = -1
        default:
            // multi-touch
            let touchArray = touches.allObjects
            let touch1 = touchArray[0] as UITouch
            let touch2 = touchArray[1] as UITouch
            let initialDistance = distanceBetweenTwoPoints(touch1.locationInView(self), toPoint: touch2.locationInView(self))
            println("Multi touch start with initial distance \(Int(initialDistance))")
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        let touch1 = touches.allObjects[0] as UITouch
        
        if (zoomed && touches.count == 1) {
            let pos : CGPoint = touch1.locationInView(self)
            self.transform = CGAffineTransformTranslate(self.transform, pos.x - startTouchPosition.x, pos.y - startTouchPosition.y);
            moved = true
            return
        }
        
        if ((initialDistance > 0) && (touches.count > 1)) {
            let touch2 = touches.allObjects[1] as UITouch
            let currentDistance = distanceBetweenTwoPoints(touch1.locationInView(self), toPoint: touch2.locationInView(self))
            let movement = currentDistance - initialDistance
            println("Touch moved: \(Int(movement))")
            if (movement != 0) {
                scale = scale * powf(2.0, movement / 100.0)
                if (scale > 2.0) {
                    scale = 2.0;
                }
                if (scale < 0.1) {
                    scale = 0.1;
                }
            }
        }
    }

    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        let touch1 = touches.allObjects[0] as UITouch
        if (touches.count == 1) {
            if (touch1.tapCount > 1) {
                println("Double tap")
                scale = 1.0
                rotation = 3.0
                return;
            }
            let currentTouchPosition : CGPoint = touch1.locationInView(self)
            
            let deltaX : Float = fabsf(Float(startTouchPosition.x) - Float(currentTouchPosition.x))
            let deltaY : Float = fabsf(Float(startTouchPosition.y) - Float(currentTouchPosition.y))
            // If the swipe tracks correctly.
            if ((deltaX >= HORIZ_SWIPE_DRAG_MIN) && (deltaY <= VERT_SWIPE_DRAG_MAX))
            {
                // It appears to be a swipe.
                let movement = startTouchPosition.x - currentTouchPosition.x;
                if (movement < 0)
                {
                    println("Swipe Right");
                    rotationSpeed = rotationSpeed + powf(2.0, Float(-movement / 100.0));
                }
                else
                {
                    rotationSpeed = rotationSpeed - powf(2.0, Float(movement / 100.0));
                    println("Swipe Left");
                }
            }
            else if (!moved && ((deltaX <= TAP_MIN_DRAG) && (deltaY <= TAP_MIN_DRAG)) )
            {
                // Process a tap event.
                println("Tap");
            }
        }
        else {
            // multi-touch
            let touch2 = touches.allObjects[1] as UITouch
            let finalDistance = distanceBetweenTwoPoints(touch1.locationInView(self), toPoint: touch2.locationInView(self))
            let movement = finalDistance - initialDistance
            println("Final Distance: \(Int(finalDistance)), movement=\(Int(movement))")
            if (movement != 0) {
                println("Movement: \(Int(movement))")
            }
        }
    }
}
