//
//  UIImage+Rotate.m
//
//  Created by Genki Kondo on 10/6/12.
//  Copyright (c) 2012 Genki Kondo. All rights reserved.
//

#import "UIImage+Rotate.h"

CGFloat degreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
CGFloat radiansToDegrees(CGFloat radians) {return radians * 180/M_PI;};

@implementation UIImage (Rotate)



/////// CLIPPING DOES NOT WORK CORRECTLY!


- (UIImage *)imageRotatedByRadians:(CGFloat)radians clip:(BOOL)clip {
    return [self imageRotatedByDegrees:radiansToDegrees(radians) clip:clip];
}

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees clip:(BOOL)clip {
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(degreesToRadians(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    // Create the bitmap context
    if (clip) {
        
        //NSLog(@"wDiff: %.2f, hDiff: %.2f", wDiff, hDiff);
        UIGraphicsBeginImageContext(self.size);
        //UIGraphicsBeginImageContext(CGSizeMake(wDiff/2.0, hDiff/2.0));
    }
    else {
        UIGraphicsBeginImageContext(rotatedSize);
    }
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    // Rotate the image context
    CGContextRotateCTM(bitmap, degreesToRadians(degrees));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    
    if (clip) {
        double wDiff = rotatedSize.width - self.size.width;
        double hDiff = rotatedSize.height - self.size.height;
        CGContextDrawImage(bitmap, CGRectMake((-self.size.width/2.0) - (wDiff/2.0), (-self.size.height/2.0) - (hDiff/2.0), self.size.width, self.size.height), [self CGImage]);
    }
    else {
        CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2.0, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    }
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
