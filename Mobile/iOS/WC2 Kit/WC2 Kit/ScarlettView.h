
#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "PLTDevice.h"


@interface ScarlettView : UIView {
@private
	GLint backingWidth;
	GLint backingHeight;
	
	EAGLContext *context;
	
	GLuint viewRenderbuffer, viewFramebuffer;
	GLuint depthRenderbuffer;
	
	BOOL animating;
	BOOL displayLinkSupported;
	NSInteger animationFrameInterval;

	id displayLink;
    NSTimer *animationTimer;
	
	UIAccelerationValue	*accel;
    
    PLTQuaternion _quat;
    GLuint textureNames[6];
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;
@property (nonatomic) UIAccelerationValue *accel;

- (void)startAnimation;
- (void)stopAnimation;
- (void)drawView;
- (void)updateRotation:(PLTQuaternion)q;

@end
