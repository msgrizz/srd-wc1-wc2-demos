//
//  OpenGLView.m
//  HelloCube
//
//  Created by Davis, Morgan on 11/2/12.
//  Copyright (c) 2012 Plantronics. All rights reserved.
//

#import "OpenGLView.h"

typedef struct {
    float Position[3];
    float Color[4];
    float TexCoord[2];
} Vertex;

#define TEX_COORD_MAX   1

//const Vertex Vertices[] = {
//    // Front
//    {{1, -1, 0}, {1, 0, 0, 1}, {TEX_COORD_MAX, 0}},
//    {{1, 1, 0}, {0, 1, 0, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
//    {{-1, 1, 0}, {0, 0, 1, 1}, {0, TEX_COORD_MAX}},
//    {{-1, -1, 0}, {0, 0, 0, 1}, {0, 0}},
//    // Back
//    {{1, 1, -2}, {1, 0, 0, 1}, {TEX_COORD_MAX, 0}},
//    {{-1, -1, -2}, {0, 1, 0, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
//    {{1, -1, -2}, {0, 0, 1, 1}, {0, TEX_COORD_MAX}},
//    {{-1, 1, -2}, {0, 0, 0, 1}, {0, 0}},
//    // Left
//    {{-1, -1, 0}, {1, 0, 0, 1}, {TEX_COORD_MAX, 0}},
//    {{-1, 1, 0}, {0, 1, 0, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
//    {{-1, 1, -2}, {0, 0, 1, 1}, {0, TEX_COORD_MAX}},
//    {{-1, -1, -2}, {0, 0, 0, 1}, {0, 0}},
//    // Right
//    {{1, -1, -2}, {1, 0, 0, 1}, {TEX_COORD_MAX, 0}},
//    {{1, 1, -2}, {0, 1, 0, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
//    {{1, 1, 0}, {0, 0, 1, 1}, {0, TEX_COORD_MAX}},
//    {{1, -1, 0}, {0, 0, 0, 1}, {0, 0}},
//    // Top
//    {{1, 1, 0}, {1, 0, 0, 1}, {TEX_COORD_MAX, 0}},
//    {{1, 1, -2}, {0, 1, 0, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
//    {{-1, 1, -2}, {0, 0, 1, 1}, {0, TEX_COORD_MAX}},
//    {{-1, 1, 0}, {0, 0, 0, 1}, {0, 0}},
//    // Bottom
//    {{1, -1, -2}, {1, 0, 0, 1}, {TEX_COORD_MAX, 0}},
//    {{1, -1, 0}, {0, 1, 0, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
//    {{-1, -1, 0}, {0, 0, 1, 1}, {0, TEX_COORD_MAX}},
//    {{-1, -1, -2}, {0, 0, 0, 1}, {0, 0}}
//};

const Vertex Vertices[] = {
    // Front
    {{1, -1, 1}, {1, 0, 0, 1}, {TEX_COORD_MAX, 0}},
    {{1, 1, 1}, {0, 1, 0, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{-1, 1, 1}, {0, 0, 1, 1}, {0, TEX_COORD_MAX}},
    {{-1, -1, 1}, {0, 0, 0, 1}, {0, 0}},
    // Back
    {{1, 1, -1}, {1, 0, 0, 1}, {TEX_COORD_MAX, 0}},
    {{-1, -1, -1}, {0, 1, 0, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{1, -1, -1}, {0, 0, 1, 1}, {0, TEX_COORD_MAX}},
    {{-1, 1, -1}, {0, 0, 0, 1}, {0, 0}},
    // Left
    {{-1, -1, 1}, {1, 0, 0, 1}, {TEX_COORD_MAX, 0}},
    {{-1, 1, 1}, {0, 1, 0, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{-1, 1, -1}, {0, 0, 1, 1}, {0, TEX_COORD_MAX}},
    {{-1, -1, -1}, {0, 0, 0, 1}, {0, 0}},
    // Right
    {{1, -1, -1}, {1, 0, 0, 1}, {TEX_COORD_MAX, 0}},
    {{1, 1, -1}, {0, 1, 0, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{1, 1, 1}, {0, 0, 1, 1}, {0, TEX_COORD_MAX}},
    {{1, -1, 1}, {0, 0, 0, 1}, {0, 0}},
    // Top
    {{1, 1, 1}, {1, 0, 0, 1}, {TEX_COORD_MAX, 0}},
    {{1, 1, -1}, {0, 1, 0, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{-1, 1, -1}, {0, 0, 1, 1}, {0, TEX_COORD_MAX}},
    {{-1, 1, 1}, {0, 0, 0, 1}, {0, 0}},
    // Bottom
    {{1, -1, -1}, {1, 0, 0, 1}, {TEX_COORD_MAX, 0}},
    {{1, -1, 1}, {0, 1, 0, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{-1, -1, 1}, {0, 0, 1, 1}, {0, TEX_COORD_MAX}},
    {{-1, -1, -1}, {0, 0, 0, 1}, {0, 0}}
};

//const Vertex Vertices2[] = {
//    {{0.75, -0.75, 0.01}, {1, 1, 1, 0}, {1, 1}},
//    {{0.75, 0.75, 0.01}, {1, 1, 1, 0}, {1, 0}},
//    {{-0.75, 0.75, 0.01}, {1, 1, 1, 0}, {0, 0}},
//    {{-0.75, -0.75, 0.01}, {1, 1, 1, 0}, {0, 1}},
//};

const Vertex Vertices2[] = {
    {{1, -1, 1.01}, {1, 1, 1, 0}, {1, 1}},
    {{1, 1, 1.01}, {1, 1, 1, 0}, {1, 0}},
    {{-1, 1, 1.01}, {1, 1, 1, 0}, {0, 0}},
    {{-1, -1, 1.01}, {1, 1, 1, 0}, {0, 1}},
};

const GLubyte Indices[] = {
    // Front
    0, 1, 2,
    2, 3, 0,
    // Back
    4, 5, 6,
    4, 5, 7,
    // Left
    8, 9, 10,
    10, 11, 8,
    // Right
    12, 13, 14,
    14, 15, 12,
    // Top
    16, 17, 18,
    18, 19, 16,
    // Bottom
    20, 21, 22,
    22, 23, 20
};

const GLubyte Indices2[] = {
    1, 0, 2, 3
};

@implementation OpenGLView

//@synthesize xSlider = _xSlider;
//@synthesize ySlider = _ySlider;
//@synthesize zSlider = _zSlider;

#pragma mark -
#pragma mark Public

- (void)updateRotation:(CC3Vector4)quat
{
    _quat = quat;
}

#pragma mark -
#pragma mark Private

- (void)setupLayer {
    _eaglLayer = (CAEAGLLayer*) self.layer;
    _eaglLayer.opaque = YES;
    
//    self.xSlider = [[UISlider alloc] initWithFrame:CGRectMake(60, 40, 128, 23)];
//    self.xSlider.minimumValue = -.5;
//    self.xSlider.maximumValue = .5;
//    self.xSlider.value = 0;
//    [self.layer addSublayer:self.xSlider.layer];
//    
//    self.ySlider = [[UISlider alloc] initWithFrame:CGRectMake(-18, 121, 128, 23)];
//    self.ySlider.minimumValue = -.5;
//    self.ySlider.maximumValue = .5;
//    self.ySlider.value = 0;
//    CGAffineTransform yTrans = CGAffineTransformMakeRotation(M_PI * 0.5);
//    self.ySlider.transform = yTrans;
//    [self.layer addSublayer:self.ySlider.layer];
//    
//    self.zSlider = [[UISlider alloc] initWithFrame:CGRectMake(35, 95, 128, 23)];
//    self.zSlider.minimumValue = -.5;
//    self.zSlider.maximumValue = .5;
//    self.zSlider.value = 0;
//    CGAffineTransform zTrans = CGAffineTransformMakeRotation(M_PI * 0.25);
//    self.zSlider.transform = zTrans;
//    [self.layer addSublayer:self.zSlider.layer];
}

- (void)setupContext {
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}

- (void)setupRenderBuffer {
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

- (void)setupFrameBuffer {
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, _colorRenderBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer);
}

- (void)render:(CADisplayLink*)displayLink {
    //glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
    glClearColor(0, 0, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);
    
    CC3GLMatrix *modelView = [CC3GLMatrix matrix];
//    [modelView populateFromTranslation:CC3VectorMake(sin(CACurrentMediaTime()), -cos(CACurrentMediaTime()),
//                                                     sin(CACurrentMediaTime()))];
    //[modelView populateFromTranslation:CC3VectorMake(sin(CACurrentMediaTime()), -cos(CACurrentMediaTime()), -6)];
    [modelView populateFromTranslation:CC3VectorMake(0, 0, -7)];
    //[modelView populateFromTranslation:CC3VectorMake(self.xSlider.value, self.ySlider.value, -7)];
//    _currentRotation += displayLink.duration * 90;
//    [modelView rotateBy:CC3VectorMake(_currentRotation, _currentRotation, 0)];

//    [modelView rotateBy:CC3VectorMake(self.ySlider.value*120, self.xSlider.value*120,
//                                      self.zSlider.value*120)];
    [modelView rotateByQuaternion:_quat];

    glUniformMatrix4fv(_modelViewUniform, 1, 0, modelView.glMatrix);
    
    CC3GLMatrix *projection = [CC3GLMatrix matrix];
    float h = 4.0f * self.frame.size.height / self.frame.size.width;
    [projection populateFromFrustumLeft:-2 andRight:2 andBottom:-h/2 andTop:h/2 andNear:4 andFar:10];
    glUniformMatrix4fv(_projectionUniform, 1, 0, projection.glMatrix);
    
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), 0);
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), (GLvoid*) (sizeof(float) * 3));
    glVertexAttribPointer(_texCoordSlot, 2, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), (GLvoid*) (sizeof(float) * 7));
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _floorTexture);
    glUniform1i(_textureUniform, 0);

    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]),
                   GL_UNSIGNED_BYTE, 0);
    
    
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer2);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer2);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _fishTexture);
    glUniform1i(_textureUniform, 0);
    
    glUniformMatrix4fv(_modelViewUniform, 1, 0, modelView.glMatrix);
    
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 3));
    glVertexAttribPointer(_texCoordSlot, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 7));
    
    glDrawElements(GL_TRIANGLE_STRIP, sizeof(Indices2)/sizeof(Indices2[0]), GL_UNSIGNED_BYTE, 0);
    
    
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType {
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName
                                                           ofType:@"glsl"];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath
                                                       encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    GLuint shaderHandle = glCreateShader(shaderType);
    
    const char * shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = [shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    glCompileShader(shaderHandle);
    
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    return shaderHandle;
}

- (void)compileShaders {
    GLuint vertexShader = [self compileShader:@"SimpleVertex" withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"SimpleFragment" withType:GL_FRAGMENT_SHADER];
    
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    glUseProgram(programHandle);
    
    _positionSlot = glGetAttribLocation(programHandle, "Position");
    _colorSlot = glGetAttribLocation(programHandle, "SourceColor");
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
    
    _projectionUniform = glGetUniformLocation(programHandle, "Projection");
    _modelViewUniform = glGetUniformLocation(programHandle, "Modelview");
    
    _texCoordSlot = glGetAttribLocation(programHandle, "TexCoordIn");
    glEnableVertexAttribArray(_texCoordSlot);
    _textureUniform = glGetUniformLocation(programHandle, "Texture");
}

- (void)setupVBOs {
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    
    glGenBuffers(1, &_indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
    
    glGenBuffers(1, &_vertexBuffer2);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer2);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices2), Vertices2, GL_STATIC_DRAW);
    
    glGenBuffers(1, &_indexBuffer2);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer2);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices2), Indices2, GL_STATIC_DRAW);
}

- (void)setupDisplayLink {
    CADisplayLink* displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)setupDepthBuffer {
    glGenRenderbuffers(1, &_depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, self.frame.size.width, self.frame.size.height);
}

- (GLuint)setupTexture:(NSString *)fileName {
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte * spriteData = (GLubyte *) calloc(width*height*4, sizeof(GLubyte));
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4,
                                                       CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    
    CGContextRelease(spriteContext);
    
    GLuint texName;
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); // linear stops the flickering you see in "smooth"
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    free(spriteData);        
    return texName;    
}

#pragma mark -
#pragma mark UIView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayer];
        [self setupContext];
        [self setupDepthBuffer];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        [self compileShaders];
        [self setupVBOs];
        [self setupDisplayLink];
        
        _floorTexture = [self setupTexture:@"green_rock_texture.jpg"];
        _fishTexture = [self setupTexture:@"zztop.png"];
    }
    return self;
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

//- (void)dealloc
//{
//    [_context release];
//    _context = nil;
////    self.xSlider = nil;
////    self.ySlider = nil;
////    self.zSlider = nil;
//    //self.quat = nil;
//    [super dealloc];
//}

@end
