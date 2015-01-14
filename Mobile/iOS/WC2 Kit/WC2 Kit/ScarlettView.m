
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import "UIDevice+ScreenSize.h"
#import "AppDelegate.h"

#import "ScarlettView.h"
#import "scarlet_hair.h"
#import "scarlet2.h" // face/head
#import "scarlet_eye_leftt.h"
#import "scarlet_eye_right.h"

//#import "scarlett_cheetah.h"


@interface ScarlettView ()

- (BOOL)createFramebuffer;
- (void)destroyFramebuffer;
- (void)setupView;

@end

@implementation ScarlettView

@synthesize animating;
@dynamic animationFrameInterval;
@synthesize accel;

- (void)updateRotation:(PLTQuaternion)q
{
	@synchronized(self) {
		_quat = q;
	}
}

+ (Class) layerClass
{
	return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame]) {
		[self _init];
	}
	return self;
}

- (id)initWithCoder:(NSCoder*)coder
{	
	if (self = [super initWithCoder:coder]) {
		[self _init];
	}
	
	return self;
}

- (void)_init
{
	CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
	//eaglLayer.backgroundColor = [UIColor colorWithWhite:(256.0-230.0)/256.0 alpha:1.0].CGColor;
	
	eaglLayer.opaque = YES;
	eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
	
	context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
	
	if (!context || ![EAGLContext setCurrentContext:context]) {
		//[self release];
		NSLog(@"Error creating EAGL context");
		return;
	}
	
	animating = FALSE;
	animationFrameInterval = 1;
	displayLink = nil;
	animationTimer = nil;
	
	accel = calloc(3, sizeof(UIAccelerationValue));
	
	[self setupView];
	[self setupDisplayLink];
	[self setupTextures];
}

-(void)setupView
{
	const GLfloat			lightAmbient[] = {0.3, 0.3, 0.3, 1.0};
	const GLfloat			lightDiffuse[] = {1.0, 1.0, 1.0, 1.0};
	const GLfloat			matAmbient[] = {0.6, 0.6, 0.6, 1.0};
	const GLfloat			matDiffuse[] = {.8, .8, .8, 1.0};
	//const GLfloat			lightPosition[] = {0.0, 0.0, 1.0, 0.0};
	const GLfloat			lightPosition[] = {0.0, 50.0, -80.0, 0.0};
	const GLfloat			lightShininess = 100.0,
	zNear = 0.1,
	zFar = 1000.0,
	fieldOfView = 60.0;
	GLfloat size;
	
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
	glEnable(GL_NORMALIZE);
	
	//Set the OpenGL projection matrix
	glMatrixMode(GL_PROJECTION);
	size = zNear * tanf(D2R(fieldOfView) / 2.0);
	CGRect rect = self.bounds;
	glFrustumf(-size, size, -size / (rect.size.width / rect.size.height), size / (rect.size.width / rect.size.height), zNear, zFar);
	glViewport(0, 0, rect.size.width, rect.size.height);
	
	
	//Make the OpenGL modelview matrix the default
	glMatrixMode(GL_MODELVIEW);
}

// Updates the OpenGL view
- (void)drawView
{
	if ([[UIApplication sharedApplication] applicationState]==UIApplicationStateActive) {
		[EAGLContext setCurrentContext:context];
		
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
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		
		//Setup model view matrix
		glLoadIdentity();
		//glTranslatef(0.0, -0.1, -1.0);
		
		// ew
		
		if (IPHONE5) {
			//glTranslatef(0.0, .052, -1.0);
			glTranslatef(0.0, 0.0, -.95);
		}
		else {
			glTranslatef(0.0, -.05, -.95);
		}
		
		//glTranslatef(0.0, .2, 0.0);
		
		glRotatef(-90.0, 0.0, 0.0, 0.0);
		
		@synchronized(self) {
			if( _quat.x || _quat.y || _quat.z || _quat.w ) {
				float scale = sqrt(_quat.x * _quat.x + _quat.y * _quat.y + _quat.z * _quat.z);
				float angle = acos(_quat.w) * 2.0f;
				BOOL mirror = [DEFAULTS boolForKey:PLTDefaultsKeyHeadMirrorImage];
				glRotatef(R2D(angle),
						  _quat.x / scale,
						  (mirror ? 1 : -1) * _quat.y / scale,
						  (mirror ? 1 : -1) * _quat.z / scale);
			}
		}
		
		
		// face
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
		
		// left eye
		glScalef(.123, .123, .123);
		glTranslatef(-0.079, .135, -0.05);
		glVertexPointer(3, GL_FLOAT, 0, scarlet_eye_lefttVerts);
		glNormalPointer(GL_FLOAT, 0, scarlet_eye_lefttNormals);
		glTexCoordPointer(2, GL_FLOAT, 0, scarlet_eye_lefttTexCoords);
		glBindTexture(GL_TEXTURE_2D, textureNames[2]);
		glTexCoordPointer(2, GL_FLOAT, 0, scarlet_eye_lefttTexCoords);
		glDrawArrays(GL_TRIANGLES, 0, scarlet_eye_lefttNumVerts);
		
		// right eye
		glTranslatef(.19, .08, 0.0);
		glVertexPointer(3, GL_FLOAT, 0, scarlet_eye_rightVerts);
		glNormalPointer(GL_FLOAT, 0, scarlet_eye_rightNormals);
		glTexCoordPointer(2, GL_FLOAT, 0, scarlet_eye_rightTexCoords);
		glBindTexture(GL_TEXTURE_2D, textureNames[3]);
		glTexCoordPointer(2, GL_FLOAT, 0, scarlet_eye_rightTexCoords);
		glDrawArrays(GL_TRIANGLES, 0, scarlet_eye_rightNumVerts);
		
		
		glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
		[context presentRenderbuffer:GL_RENDERBUFFER_OES];

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
	[EAGLContext setCurrentContext:context];
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
	[context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(id<EAGLDrawable>)self.layer];
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
	
	return YES;
}

// Clean up any buffers we have allocated.
- (void)destroyFramebuffer
{
	glDeleteFramebuffersOES(1, &viewFramebuffer);
	viewFramebuffer = 0;
	glDeleteRenderbuffersOES(1, &viewRenderbuffer);
	viewRenderbuffer = 0;
	
	if(depthRenderbuffer) {
		glDeleteRenderbuffersOES(1, &depthRenderbuffer);
		depthRenderbuffer = 0;
	}
}

- (NSInteger)animationFrameInterval
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
	if (frameInterval >= 1) {
		animationFrameInterval = frameInterval;
		
		if (animating) {
			[self stopAnimation];
			[self startAnimation];
		}
	}
}

- (void)startAnimation
{
	if (!animating) {
		// CADisplayLink is API new to iPhone SDK 3.1. Compiling against earlier versions will result in a warning, but can be dismissed
		// if the system version runtime check for CADisplayLink exists in -initWithCoder:. The runtime check ensures this code will
		// not be called in system versions earlier than 3.1.
		
		displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(drawView)];
		[displayLink setFrameInterval:animationFrameInterval];
		[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		
		animating = TRUE;
	}
}

- (void)stopAnimation
{
	if (animating) {
		[displayLink invalidate];
		displayLink = nil;
		animating = FALSE;
	}
}

- (void)setupDisplayLink
{
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
	
	// added by Morgan: smooth the texture scaling
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); // linear stops the flickering you see in "smooth"
	
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
	
	CGContextRelease(cgContext);
	
	free(imageData);
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

@end
