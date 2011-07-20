//
//  GraphView.m
//  GraphingCalculator
//
//  Created by Jeff Poetker on 7/18/11.
//  Copyright 2011 Medplus, Inc. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"


@implementation GraphView

@synthesize delegate;
@synthesize scale, useLines;

-(void) setup 
{
    self.useLines = YES;
    self.scale = 14;
}

- (void)awakeFromNib {
    [self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (double) convertXPixelToGraphValueX: (CGFloat) x originAtPoint: (CGPoint) midPoint scale: (CGFloat) s
{
    return ((x - midPoint.x) / s);
}

- (CGFloat) convertYValueToYPixel: (double) y originAtPoint: (CGPoint) midPoint scale: (CGFloat) s
{
    return (-1 * y * s) + midPoint.y;
}

- (void)drawRect:(CGRect)rect
{
    if (!self.scale) self.scale = 14;
    
    CGFloat scaleFactor = self.contentScaleFactor;
    
    
    CGPoint midPoint;
    midPoint.x = self.bounds.origin.x + self.bounds.size.width/2;
    midPoint.y = self.bounds.origin.y + self.bounds.size.height/2;
    
    CGContextRef context = UIGraphicsGetCurrentContext();

    // Drawing code
    NSLog(@"Drawing axis for scale %f", self.scale); 
    [AxesDrawer drawAxesInRect:rect originAtPoint:midPoint scale:self.scale];

    BOOL lineInitialized = NO;
    for(double x = 0;x<self.bounds.size.width;x=x+(1/scaleFactor)) {
        double xValue = [self convertXPixelToGraphValueX:x originAtPoint:midPoint scale:self.scale];
        double yValue = [delegate yValueGiven: xValue for: self];
        CGFloat y = [self convertYValueToYPixel:yValue originAtPoint:midPoint scale:self.scale];
//        NSLog(@"%f = %f", xValue, yValue);
//        NSLog(@"Pixels: (%d, %f)", x, y);
        
        CGPoint graphPoint;
        graphPoint.x = x;
        graphPoint.y = y;        
//        if (CGRectContainsPoint(self.bounds, graphPoint)) {
            if (self.useLines) {
                if (!lineInitialized) {
                    lineInitialized = YES;
                    CGContextMoveToPoint(context, graphPoint.x, graphPoint.y);
                } else {
                    CGContextAddLineToPoint(context, graphPoint.x, graphPoint.y);
                }

            } else {
                CGRect point = CGRectMake(graphPoint.x, graphPoint.y, .5, .5);
                CGContextAddRect(context, point);
                CGContextStrokePath(context);
            }
//        }
    }
    
    if (self.useLines) {
        CGContextDrawPath(context, kCGPathStroke);
    }
    
}

- (void)dealloc
{
    [super dealloc];
}

@end
