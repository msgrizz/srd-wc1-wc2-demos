//
//  OpenGLView.h
//  HelloCube
//
//  Created by Davis, Morgan on 11/2/12.
//  Copyright (c) 2012 Plantronics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#import "CC3GLMatrix.h"

@interface OpenGLView : UIView {
    CAEAGLLayer* _eaglLayer;
    EAGLContext* _context;
    GLuint _colorRenderBuffer;
    GLuint _positionSlot;
    GLuint _colorSlot;
    GLuint _projectionUniform;
    GLuint _modelViewUniform;
    float _currentRotation;
    GLuint _depthRenderBuffer;
    GLuint _floorTexture;
    GLuint _fishTexture;
    GLuint _texCoordSlot;
    GLuint _textureUniform;
    GLuint _vertexBuffer;
    GLuint _indexBuffer;
    GLuint _vertexBuffer2;
    GLuint _indexBuffer2;
    CC3Vector4 _quat;
    
//    UISlider *_xSlider;
//    UISlider *_ySlider;
//    UISlider *_zSlider;
}

//@property(nonatomic,assign) UISlider *xSlider;
//@property(nonatomic,assign) UISlider *ySlider;
//@property(nonatomic,assign) UISlider *zSlider;

- (void)updateRotation:(CC3Vector4)quat;

@end
