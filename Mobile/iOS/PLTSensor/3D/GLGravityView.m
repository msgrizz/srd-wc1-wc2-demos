/*
     File: GLGravityView.m
 Abstract: This class wraps the CAEAGLLayer from CoreAnimation into a convenient
 UIView subclass. The view content is basically an EAGL surface you render your
 OpenGL scene into.  Note that setting the view non-opaque will only work if the
 EAGL surface has an alpha channel.
  Version: 2.2
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
*/

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import "UIDevice+ScreenSize.h"
#import "AppDelegate.h"

#import "GLGravityView.h"
//#import "teapot.h"
//#import "banana.h"
//#import "scarlettobj.h"
//#import "scarlett_no_bowl.h"
#import "scarlet_hair.h"
#import "scarlet2.h" // face/head
#import "scarlet_eye_leftt.h"
#import "scarlet_eye_right.h"

// CONSTANTS
#define kTeapotScale				1.0

// MACROS
#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)
#define RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) * 180.0 / M_PI)

// A class extension to declare private methods
@interface GLGravityView () {
    //BOOL iPhone5; // haaaaaccckkkkkk
}

- (BOOL)createFramebuffer;
- (void)destroyFramebuffer;
- (void)setupView;

@end

@implementation GLGravityView

@synthesize animating;
@dynamic animationFrameInterval;
@synthesize accel;

- (void)updateRotation:(Vec4)rot
{
	CC3Vector4 cc3Vector = { rot.x, rot.y, rot.z, rot.w };
	@synchronized(self) {
		_quat = cc3Vector;
	}
}

// Implement this to override the default layer class (which is [CALayer class]).
// We do this so that our view will be backed by a layer that is capable of OpenGL ES rendering.
+ (Class) layerClass
{
	return [CAEAGLLayer class];
}

// The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder {
    
    if ((self = [super initWithCoder:coder])) {
        
        //self.contentScaleFactor = 2.0;
        
		CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        //eaglLayer.backgroundColor = [UIColor colorWithWhite:(256.0-230.0)/256.0 alpha:1.0].CGColor;
	
		eaglLayer.opaque = YES;
		eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
	
		eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
	
		if (!eaglContext || ![EAGLContext setCurrentContext:eaglContext]) {
			//[self release];
			return nil;
		}
	
		animating = FALSE;
		displayLinkSupported = FALSE;
		animationFrameInterval = 1;
		displayLink = nil;
		animationTimer = nil;
        
        // this little bit it a total hack to work-around some NIB UI layout weirdness with the iPhone 5's 4" screen...
//        if (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) && [UIDevice hasFourInchDisplay]) {
//            iPhone5 = YES;
//        }
	
		// A system version of 3.1 or greater is required to use CADisplayLink. The NSTimer
		// class is used as fallback when it isn't available.
		NSString *reqSysVer = @"3.1";
		NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
		if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
			displayLinkSupported = TRUE;
		
		accel = calloc(3, sizeof(UIAccelerationValue));
		
		[self setupView];
        [self setupDisplayLink];
        [self setupTextures];
	}
	
	return self;
}
	
-(void)setupView
{
    const GLfloat			lightAmbient[] = {0.3, 0.3, 0.3, 1.0};
	const GLfloat			lightDiffuse[] = {1.0, 1.0, 1.0, 1.0};
	const GLfloat			matAmbient[] = {0.6, 0.6, 0.6, 1.0};
    const GLfloat			matDiffuse[] = {.8, .8, .8, 1.0};
	const GLfloat			matSpecular[] = {1.0, 1.0, 1.0, 1.0};
	//const GLfloat			lightPosition[] = {0.0, 0.0, 1.0, 0.0};
    const GLfloat			lightPosition[] = {0.0, 50.0, -80.0, 0.0};
	const GLfloat			lightShininess = 100.0,
							zNear = 0.1,
							zFar = 1000.0,
							fieldOfView = 60.0;
	GLfloat					size;
	
	//Configure OpenGL lighting
	glEnable(GL_LIGHTING);
	glEnable(GL_LIGHT0);
	glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, matAmbient);
	glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, matDiffuse);
	//glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, matSpecular);
	glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, lightShininess);
	glLightfv(GL_LIGHT0, GL_AMBIENT, lightAmbient);
	glLightfv(GL_LIGHT0, GL_DIFFUSE, lightDiffuse);
	glLightfv(GL_LIGHT0, GL_POSITION, lightPosition);
	glShadeModel(GL_SMOOTH);
	glEnable(GL_DEPTH_TEST);
	
		
	//Configure OpenGL arrays
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_NORMAL_ARRAY);
//	glVertexPointer(3 ,GL_FLOAT, 0, teapot_vertices);
//	glNormalPointer(GL_FLOAT, 0, teapot_normals);
    
//    glVertexPointer(3, GL_FLOAT, 0, bananaVerts);
//    glNormalPointer(GL_FLOAT, 0, bananaNormals);
//    glTexCoordPointer(2, GL_FLOAT, 0, bananaTexCoords);

//    glVertexPointer(3, GL_FLOAT, 0, scarlettobjVerts);
//    glNormalPointer(GL_FLOAT, 0, scarlettobjNormals);
//    glTexCoordPointer(2, GL_FLOAT, 0, scarlettobjTexCoords);

//    // works well
//    glVertexPointer(3, GL_FLOAT, 0, scarlett_no_bowlVerts);
//    glNormalPointer(GL_FLOAT, 0, scarlett_no_bowlNormals);
//    glTexCoordPointer(2, GL_FLOAT, 0, scarlett_no_bowlTexCoords);
    
//    glVertexPointer(3, GL_FLOAT, 0, scarlet_hairVerts);
//    glNormalPointer(GL_FLOAT, 0, scarlet_hairNormals);
//    glTexCoordPointer(2, GL_FLOAT, 0, scarlet_hairTexCoords);
//    
//    glVertexPointer(3, GL_FLOAT, 0, scarlet2Verts);
//    glNormalPointer(GL_FLOAT, 0, scarlet2Normals);
//    glTexCoordPointer(2, GL_FLOAT, 0, scarlet2TexCoords);
    
    
//    GLfloat *verts = malloc(sizeof(GLfloat)*3*scarlet_hairNumVerts*scarlet2NumVerts);
//    GLfloat *norms = malloc(sizeof(GLfloat)*3*scarlet_hairNumNormals*scarlet2NumNormals);
//    GLfloat *texCoords = malloc(sizeof(GLfloat)*3*scarlet_hairNumVerts*scarlet2NumVerts);
    
    
	glEnable(GL_NORMALIZE);

	//Set the OpenGL projection matrix
	glMatrixMode(GL_PROJECTION);
	size = zNear * tanf(DEGREES_TO_RADIANS(fieldOfView) / 2.0);
	CGRect rect = self.bounds;
	glFrustumf(-size, size, -size / (rect.size.width / rect.size.height), size / (rect.size.width / rect.size.height), zNear, zFar);
	glViewport(0, 0, rect.size.width, rect.size.height);
    
    
//    // multisampling
//    glBindFramebuffer(GL_FRAMEBUFFER, multisampleFramebuffer);
//    glViewport(0, 0, rect.size.width, rect.size.height);
//    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
	
	//Make the OpenGL modelview matrix the default
	glMatrixMode(GL_MODELVIEW);
}

// Updates the OpenGL view
- (void)drawView
{
    if([[UIApplication sharedApplication] applicationState]==UIApplicationStateActive)
    {
        [EAGLContext setCurrentContext:eaglContext];
        
        glEnableClientState(GL_VERTEX_ARRAY);
        glEnableClientState(GL_NORMAL_ARRAY);
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
        
        const GLfloat lightPosition[] = {0.0, 50.0, 80.0, 0.0};
        glEnable(GL_LIGHT0);
        glLightfv(GL_LIGHT0, GL_POSITION, lightPosition);
        glShadeModel(GL_SMOOTH);
        glEnable(GL_DEPTH_TEST);
        
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
        glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        //glClearColor(0.0f, 0.0f, 0.0f, (256.0-230.0)/256.0);
        //glClearColor(230.0/256.0, 230.0/256.0, 230.0/256.0, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        //Setup model view matrix
        glLoadIdentity();
        //glTranslatef(0.0, -0.1, -1.0);
		
		// yuck yuck yuck yuck!
		
        if (IPHONE5) {
            //glTranslatef(0.0, .052, -1.0);
			glTranslatef(0.0, 0.0, -.95);
        }
        else {
            glTranslatef(0.0, -.05, -.95);
        }
		
//		if (!IOS7 && !IPHONE5) {
//			glTranslatef(0.0, -.4, 0.0);
//		}
		
		//glTranslatef(0.0, .2, 0.0);
        
        glRotatef(-90.0, 0.0, 0.0, 0.0);
        
		@synchronized(self) {
//			if( _quat.x || _quat.y || _quat.z || _quat.w ) {
//				float scale = sqrt(_quat.x * _quat.x + _quat.y * _quat.y + _quat.z * _quat.z);
//				float angle = acos(_quat.w) * 2.0f;
//				glRotatef(RADIANS_TO_DEGREES(angle), _quat.x / scale, _quat.y / scale, _quat.z / scale);
//			}
			if( _quat.x || _quat.y || _quat.z || _quat.w ) {
				float scale = sqrt(_quat.x * _quat.x + _quat.y * _quat.y + _quat.z * _quat.z);
				float angle = acos(_quat.w) * 2.0f;
				BOOL mirror = [DEFAULTS boolForKey:PLTDefaultsKey3DHeadMirrorImage];
				glRotatef(RADIANS_TO_DEGREES(angle),
						  _quat.x / scale,
						  (mirror ? 1 : -1) * _quat.y / scale,
						  (mirror ? 1 : -1) * _quat.z / scale);
			}
		}
        
        
        // face
        //glScalef(1, 1, .9);
        glVertexPointer(3, GL_FLOAT, 0, scarlet2Verts);
        glNormalPointer(GL_FLOAT, 0, scarlet2Normals);
        glTexCoordPointer(2, GL_FLOAT, 0, scarlet2TexCoords);
        glBindTexture(GL_TEXTURE_2D, textureNames[1]);
        glTexCoordPointer(2, GL_FLOAT, 0, scarlet2TexCoords);
        glDrawArrays(GL_TRIANGLES, 0, scarlet2NumVerts);
        
        
        // hair
        glScalef(.88, .88, .88);
        glVertexPointer(3, GL_FLOAT, 0, scarlet_hairVerts);
        glNormalPointer(GL_FLOAT, 0, scarlet_hairNormals);
        glTexCoordPointer(2, GL_FLOAT, 0, scarlet_hairTexCoords);
        glBindTexture(GL_TEXTURE_2D, textureNames[0]);
        glTexCoordPointer(2, GL_FLOAT, 0, scarlet_hairTexCoords);
        glDrawArrays(GL_TRIANGLES, 0, scarlet_hairNumVerts);
        
        
        
        // eyes
        glScalef(.123, .123, .123);
        glTranslatef(-0.079, .135, -0.05);
        glVertexPointer(3, GL_FLOAT, 0, scarlet_eye_lefttVerts);
        glNormalPointer(GL_FLOAT, 0, scarlet_eye_lefttNormals);
        glTexCoordPointer(2, GL_FLOAT, 0, scarlet_eye_lefttTexCoords);
        glBindTexture(GL_TEXTURE_2D, textureNames[2]);
        glTexCoordPointer(2, GL_FLOAT, 0, scarlet_eye_lefttTexCoords);
        glDrawArrays(GL_TRIANGLES, 0, scarlet_eye_lefttNumVerts);
        
        glTranslatef(.19, .08, 0.0);
        glVertexPointer(3, GL_FLOAT, 0, scarlet_eye_rightVerts);
        glNormalPointer(GL_FLOAT, 0, scarlet_eye_rightNormals);
        glTexCoordPointer(2, GL_FLOAT, 0, scarlet_eye_rightTexCoords);
        glBindTexture(GL_TEXTURE_2D, textureNames[3]);
        glTexCoordPointer(2, GL_FLOAT, 0, scarlet_eye_rightTexCoords);
        glDrawArrays(GL_TRIANGLES, 0, scarlet_eye_rightNumVerts);
        
        
        
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
        [eaglContext presentRenderbuffer:GL_RENDERBUFFER_OES];
        
//        // multisampling
//        glBindRenderbuffer(GL_RENDERBUFFER, multisampleFramebuffer);
//        [context presentRenderbuffer:GL_RENDERBUFFER];
        
        glDisableClientState(GL_VERTEX_ARRAY);
        glDisableClientState(GL_NORMAL_ARRAY);
        glDisableClientState(GL_TEXTURE_COORD_ARRAY);
        
    }
}

// If our view is resized, we'll be asked to layout subviews.
// This is the perfect opportunity to also update the framebuffer so that it is
// the same size as our display area.
-(void)layoutSubviews
{
	[EAGLContext setCurrentContext:eaglContext];
	[self destroyFramebuffer];
	[self createFramebuffer];
	[self drawView];
}

- (BOOL)createFramebuffer
{
	// Generate IDs for a framebuffer object and a color renderbuffer
	glGenFramebuffersOES(1, &viewFramebuffer);
	glGenRenderbuffersOES(1, &viewRenderbuffer);
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	// This call associates the storage for the current render buffer with the EAGLDrawable (our CAEAGLLayer)
	// allowing us to draw into a buffer that will later be rendered to screen wherever the layer is (which corresponds with our view).
	[eaglContext renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(id<EAGLDrawable>)self.layer];
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
	
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
	
	// For this sample, we also need a depth buffer, so we'll create and attach one via another renderbuffer.
	glGenRenderbuffersOES(1, &depthRenderbuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
	glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);

	if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
		NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
		return NO;
	}
    
    
    
//    // multisample buffer
//    
//    glGenFramebuffers(1, &multisampleFramebuffer);
//    glBindFramebuffer(GL_FRAMEBUFFER, multisampleFramebuffer);
//    
//    glGenRenderbuffers(1, &multisampleFramebuffer);
//    glBindRenderbuffer(GL_RENDERBUFFER, multisampleFramebuffer);
//    glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, 4, GL_RGBA8_OES, backingWidth, backingHeight);
//    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, multisampleFramebuffer);
//    
//    glGenRenderbuffers(1, &multisampleFramebuffer);
//    glBindRenderbuffer(GL_RENDERBUFFER, multisampleFramebuffer);
//    glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, 4, GL_DEPTH_COMPONENT16, backingWidth, backingHeight);
//    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, multisampleFramebuffer);
//    
//    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
//        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
    
    
    
    
	
	return YES;
}

// Clean up any buffers we have allocated.
- (void)destroyFramebuffer
{
	glDeleteFramebuffersOES(1, &viewFramebuffer);
	viewFramebuffer = 0;
	glDeleteRenderbuffersOES(1, &viewRenderbuffer);
	viewRenderbuffer = 0;
	
	if(depthRenderbuffer)
	{
		glDeleteRenderbuffersOES(1, &depthRenderbuffer);
		depthRenderbuffer = 0;
	}
}

- (NSInteger) animationFrameInterval
{
	return animationFrameInterval;
}

- (void) setAnimationFrameInterval:(NSInteger)frameInterval
{
	// Frame interval defines how many display frames must pass between each time the
	// display link fires. The display link will only fire 30 times a second when the
	// frame internal is two on a display that refreshes 60 times a second. The default
	// frame interval setting of one will fire 60 times a second when the display refreshes
	// at 60 times a second. A frame interval setting of less than one results in undefined
	// behavior.
	if (frameInterval >= 1)
	{
		animationFrameInterval = frameInterval;
		
		if (animating)
		{
			[self stopAnimation];
			[self startAnimation];
		}
	}
}

- (void) startAnimation
{
    //return;
    
	if (!animating)
	{
		if (displayLinkSupported)
		{
			// CADisplayLink is API new to iPhone SDK 3.1. Compiling against earlier versions will result in a warning, but can be dismissed
			// if the system version runtime check for CADisplayLink exists in -initWithCoder:. The runtime check ensures this code will
			// not be called in system versions earlier than 3.1.
			
			displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(drawView)];
			[displayLink setFrameInterval:animationFrameInterval];
			[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		}
		else
			animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0) * animationFrameInterval) target:self selector:@selector(drawView) userInfo:nil repeats:TRUE];
		
		animating = TRUE;
	}
}

- (void)stopAnimation
{
	if (animating)
	{
		if (displayLinkSupported)
		{
			[displayLink invalidate];
			displayLink = nil;
		}
		else
		{
			[animationTimer invalidate];
			animationTimer = nil;
		}
		
		animating = FALSE;
	}
}

- (void)setupDisplayLink {
    CADisplayLink* displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawView)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)setupTextures
{
    // enable textures
    glEnable(GL_TEXTURE_2D);
    glEnable(GL_BLEND);
    //glBlendFunc(GL_ONE, GL_SRC_COLOR);
    glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    // create texture names
    glGenTextures(6, &textureNames[0]);
    
    // load texture
    NSString *path = [[NSBundle mainBundle] pathForResource:@"hair_1024_withalph" ofType:@"png"];
    [self loadTextureAtPath:path name:textureNames[0]];
//    NSString *maskPath = [[NSBundle mainBundle] pathForResource:@"hair_alph_1024" ofType:@"png"];
//    [self loadTextureAtPath:path maskPath:maskPath name:textureNames[0]];
    
    path = [[NSBundle mainBundle] pathForResource:@"Scarlet2" ofType:@"jpg"];
    [self loadTextureAtPath:path name:textureNames[1]];
    path = [[NSBundle mainBundle] pathForResource:@"Scarlet_eye_right" ofType:@"jpg"];
    [self loadTextureAtPath:path name:textureNames[2]];
    path = [[NSBundle mainBundle] pathForResource:@"Scarlet_eye_left" ofType:@"jpg"];
    [self loadTextureAtPath:path name:textureNames[3]];
}

- (void)loadTextureAtPath:(NSString *)texPath name:(GLuint)texName
{
    // added by Morgan: make texName the active texture
    glBindTexture(GL_TEXTURE_2D, texName);
    
    // added by Morgan: disable mipmapping
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"texture" ofType:@"png"];
    NSData *texData = [[NSData alloc] initWithContentsOfFile:texPath];
    UIImage *image = [[UIImage alloc] initWithData:texData];
    if (image == nil)
        NSLog(@"*** Error creating UIImage. ***");
    
    GLuint width = CGImageGetWidth(image.CGImage);
    GLuint height = CGImageGetHeight(image.CGImage);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc( height * width * 4 );
    //CGContextRef cgContext = CGBitmapContextCreate( imageData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
    CGContextRef cgContext = CGBitmapContextCreate( imageData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
    CGContextTranslateCTM (cgContext, 0, height);
    CGContextScaleCTM (cgContext, 1.0, -1.0);
    CGColorSpaceRelease( colorSpace );
    CGContextClearRect( cgContext, CGRectMake( 0, 0, width, height ) );
    CGContextTranslateCTM( cgContext, 0, height - height );
    CGContextDrawImage( cgContext, CGRectMake( 0, 0, width, height ), image.CGImage );
    
    // added by Morgan: smooth the texture scaling
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); // linear stops the flickering you see in "smooth"
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    
    CGContextRelease(cgContext);
    
    free(imageData);
//    [image release];
//    [texData release];
}

//- (void)loadTextureAtPath:(NSString *)texPath maskPath:(NSString *)maskPath name:(GLuint)texName
//{
//    // added by Morgan: make texName the active texture
//    glBindTexture(GL_TEXTURE_2D, texName);
//    
//    // added by Morgan: disable mipmapping
//    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
//    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
//    
//    //NSString *path = [[NSBundle mainBundle] pathForResource:@"texture" ofType:@"png"];
//    NSData *texData = [[NSData alloc] initWithContentsOfFile:texPath];
//    UIImage *image = [[UIImage alloc] initWithData:texData];
//    if (image == nil)
//        NSLog(@"*** Error creating UIImage. ***");
//    
//    GLuint width = CGImageGetWidth(image.CGImage);
//    GLuint height = CGImageGetHeight(image.CGImage);
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    void *imageData = malloc( height * width * 4 );
//    CGContextRef cgContext = CGBitmapContextCreate( imageData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
//    CGContextTranslateCTM (cgContext, 0, height);
//    CGContextScaleCTM (cgContext, 1.0, -1.0);
//    CGColorSpaceRelease( colorSpace );
//    CGContextClearRect( cgContext, CGRectMake( 0, 0, width, height ) );
//    CGContextTranslateCTM( cgContext, 0, height - height );
//    
//     CGContextDrawImage( cgContext, CGRectMake( 0, 0, width, height ), image.CGImage );
//    
//    
//    CGContextSetBlendMode(cgContext, kCGBlendModeSourceIn);
//    
//    
//    UIImage *maskImage = [UIImage imageWithContentsOfFile:maskPath];
//    NSLog(@"maskImage: %@",maskImage);
//    //CGContextClipToMask(cgContext, CGRectMake(0, 0, width, height), maskImage.CGImage);
//    
//    
//    CGContextDrawImage( cgContext, CGRectMake( 0, 0, width, height ), maskImage.CGImage );
//
//
//    
//    
//    // added by Morgan: smooth the texture scaling
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); // linear stops the flickering you see in "smooth"
//    
//    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
//    
//    CGContextRelease(cgContext);
//    
//    free(imageData);
//    [image release];
//    [texData release];
//}

- (void)loadTextureAtPath:(NSString *)texPath maskPath:(NSString *)maskPath name:(GLuint)texName
{
    // added by Morgan: make texName the active texture
    glBindTexture(GL_TEXTURE_2D, texName);
    
    // added by Morgan: disable mipmapping
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"texture" ofType:@"png"];
    NSData *texData = [[NSData alloc] initWithContentsOfFile:texPath];
    UIImage *image = [[UIImage alloc] initWithData:texData];
    if (image == nil)
        NSLog(@"*** Error creating UIImage. ***");
    
    
    UIImage *maskImage = [UIImage imageWithContentsOfFile:maskPath];
    image = [self maskImage:[UIImage imageWithData:texData] withMask:maskImage];
    
    
    GLuint width = CGImageGetWidth(image.CGImage);
    GLuint height = CGImageGetHeight(image.CGImage);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc( height * width * 4 );
    CGContextRef cgContext = CGBitmapContextCreate( imageData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
    CGContextTranslateCTM (cgContext, 0, height);
    CGContextScaleCTM (cgContext, 1.0, -1.0);
    CGColorSpaceRelease( colorSpace );
    CGContextClearRect( cgContext, CGRectMake( 0, 0, width, height ) );
    CGContextTranslateCTM( cgContext, 0, height - height );
    
    CGContextDrawImage( cgContext, CGRectMake( 0, 0, width, height ), image.CGImage );
    
    
//    CGContextSetBlendMode(cgContext, kCGBlendModeDestinationIn);
//    //CGContextClipToMask(cgContext, CGRectMake(0, 0, width, height), maskImage.CGImage);
//    CGContextDrawImage( cgContext, CGRectMake( 0, 0, width, height ), maskImage.CGImage );
    
    
    
    
    // added by Morgan: smooth the texture scaling
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); // linear stops the flickering you see in "smooth"
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    
    CGContextRelease(cgContext);
    
    free(imageData);
    //[image release];
    //[texData release];
}

- (UIImage*)maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    
	CGImageRef maskRef = maskImage.CGImage;
    
	CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
	CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
    UIImage *maskedImage = [UIImage imageWithCGImage:masked];
    CGImageRelease(masked);
    CGImageRelease(mask);
	return maskedImage;
    
}

//- (void)dealloc
//{
//	free(accel);
//	
//	if([EAGLContext currentContext] == context)
//	{
//		[EAGLContext setCurrentContext:nil];
//	}
//	
//	[context release];
//	[super dealloc];
//}

@end
