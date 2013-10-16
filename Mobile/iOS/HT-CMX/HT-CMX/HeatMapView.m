//
//  HeatMapView.m
//  HeatMapTest
//
//  Created by Davis, Morgan on 10/15/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "HeatMapView.h"
#import <CoreGraphics/CoreGraphics.h>


// This sets the spread of the heat from each map point (in screen pts.)
static const NSInteger kSBHeatRadiusInPoints = 32; // default 48

// These affect the transparency of the heatmap
// Colder areas will be more transparent
// Currently the alpha is a two piece linear function of the value
// Play with the pivot point and max alpha to affect the look of the heatmap

// This number should be between 0 and 1
//static const CGFloat kSBAlphaPivotX = 0.333;
static const CGFloat kSBAlphaPivotX = 0.333;

// This number should be between 0 and MAX_ALPHA
//static const CGFloat kSBAlphaPivotY = 0.5;
static const CGFloat kSBAlphaPivotY = 0.5;

// This number should be between 0 and 1
static const CGFloat kSBMaxAlpha = 0.55;


@interface HeatMapView ()

- (void)populateScaleMatrix;
- (void)colorForValue:(double)value red:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha;

@property(nonatomic, strong)	NSDictionary	*pointsWithHeat;
@property(nonatomic, readonly)	float			*scaleMatrix;

@end


@implementation HeatMapView

@synthesize scaleMatrix = _scaleMatrix;

#pragma mark - Public

- (id)initWithData:(NSDictionary *)heatMapData 
{
    if (self = [super init]) {
        [self setData:heatMapData];
    }
    return self;
}

- (void)populateScaleMatrix
{
    for(int i = 0; i < 2 * kSBHeatRadiusInPoints; i++) {
        for(int j = 0; j < 2 * kSBHeatRadiusInPoints; j++) {
            float distance = sqrt((i - kSBHeatRadiusInPoints) * (i - kSBHeatRadiusInPoints) + (j - kSBHeatRadiusInPoints) * (j - kSBHeatRadiusInPoints));
            float scaleFactor = 1 - distance / kSBHeatRadiusInPoints;
            if (scaleFactor < 0) {
                scaleFactor = 0;
            } else {
                scaleFactor = (expf(-distance/10.0) - expf(-kSBHeatRadiusInPoints/10.0)) / expf(0);
            }
            _scaleMatrix[j * 2 * kSBHeatRadiusInPoints + i] = scaleFactor;
        }
    }
}

- (void)setData:(NSDictionary *)newHeatMapData
{        
	self.pointsWithHeat = newHeatMapData;
	_scaleMatrix = malloc(2 * kSBHeatRadiusInPoints * 2 * kSBHeatRadiusInPoints * sizeof(float));
	[self populateScaleMatrix];
}

#pragma mark - Private

- (void)colorForValue:(double)value red:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha
{
    if (value > 1) value = 1;
    value = sqrt(value);
    
    if (value < kSBAlphaPivotY) {
        *alpha = value * kSBAlphaPivotY / kSBAlphaPivotX;
    } else {
        *alpha = kSBAlphaPivotY + ((kSBMaxAlpha - kSBAlphaPivotY) / (1 - kSBAlphaPivotX)) * (value - kSBAlphaPivotX);
    }
    
    //formula converts a number from 0 to 1.0 to an rgb color.
    //uses MATLAB/Octave colorbar code
    if(value <= 0) { 
        *red = *green = *blue = *alpha = 0;
    } else if(value < 0.125) {
        *red = *green = 0;
        *blue = 4 * (value + 0.125);
    } else if(value < 0.375) {
        *red = 0;
        *green = 4 * (value - 0.125);
        *blue = 1;
    } else if(value < 0.625) {
        *red = 4 * (value - 0.375);
        *green = 1;
        *blue = 1 - 4 * (value - 0.375);
    } else if(value < 0.875) {
        *red = 1;
        *green = 1 - 4 * (value - 0.625);
        *blue = 0;
    } else {
        *red = MAX(1 - 4 * (value - 0.875), 0.5);
        *green = *blue = 0;
    }
}

#pragma mark - UIView

- (void)drawRect:(CGRect)rect
{
	//CGFloat zoomScale = .5;
	CGFloat zoomScale = .5;
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextClearRect(context, rect);
	
	int columns = ceil(CGRectGetWidth(rect) * zoomScale);
	int rows = ceil(CGRectGetHeight(rect) * zoomScale);
	int arrayLen = columns * rows;
	
	// allocate an array matching the screen point size of the rect
	float *pointValues = calloc(arrayLen, sizeof(float));

	if (pointValues) {
		NSDictionary *heat = self.pointsWithHeat;
		
		for (NSValue *key in heat) {
			//convert key to point
			CGPoint point;
			[key getValue:&point];
			double value = [[heat objectForKey:key] doubleValue];
			
			CGPoint matrixCoord = CGPointMake((point.x - rect.origin.x) * zoomScale, 
											  (point.y - rect.origin.y) * zoomScale);
			
			if (value > 0) { // don't bother with 0 or negative values
				// iterate through surrounding pixels and increase
				for(int i = 0; i < 2 * kSBHeatRadiusInPoints; i++) {
					for(int j = 0; j < 2 * kSBHeatRadiusInPoints; j++) {
						// find the array index
						int column = floor(matrixCoord.x - kSBHeatRadiusInPoints + i);
						int row = floor(matrixCoord.y - kSBHeatRadiusInPoints + j);
						
						// make sure this is a valid array index
						if(row >= 0 && column >= 0 && row < rows && column < columns) {
							int index = columns * row + column;
							pointValues[index] += value * _scaleMatrix[j * 2 * kSBHeatRadiusInPoints + i];
						}
					}
				}
			}
		}
		
		for (int i = 0; i < arrayLen; i++) {
			if (pointValues[i] > 0) {
				int column = i % columns;
				int row = i / columns;
				CGFloat red, green, blue, alpha;
				
				[self colorForValue:pointValues[i] red:&red green:&green blue:&blue alpha:&alpha];
				CGContextSetRGBFillColor(context, red, green, blue, alpha);
				
				//scale back up to userSpace
				CGRect matchingUsRect = CGRectMake(rect.origin.x + column / zoomScale, 
												   rect.origin.y + row / zoomScale, 
												   1.0/zoomScale, 
												   1.0/zoomScale);
				CGContextFillRect(context, matchingUsRect);
			}
		}
		
		free(pointValues);
	}
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

@end
