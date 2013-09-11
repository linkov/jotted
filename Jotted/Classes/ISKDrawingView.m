//
//  ISKDrawingView.m
//  IndexStack
//
//  Created by Alexey Linkov on 9/2/12.
//  Copyright (c) 2012 Alexey Linkov. All rights reserved.
//
#import "ISKDrawingView.h"

@interface ISKDrawingView () {
    
    CGPoint previousPoint;
}

@end

@implementation ISKDrawingView
@synthesize mainPath,brush;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
                
        self.backgroundColor=[UIColor clearColor];
        mainPath=[[UIBezierPath alloc]init];
        mainPath.lineCapStyle=kCGLineCapRound;
        mainPath.miterLimit=0;
        mainPath.lineWidth=2;
        
        
        UITapGestureRecognizer *deleteTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clearPath)];
        deleteTap.numberOfTouchesRequired = 2;
        deleteTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:deleteTap];
        [deleteTap release];
        
        // Capture touches
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        pan.maximumNumberOfTouches = pan.minimumNumberOfTouches = 1;
        [self addGestureRecognizer:pan];

        
    }
    return self;
}

-(void)clearPath {
    
    [mainPath removeAllPoints];
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect
{
    [brush setStroke];
    [mainPath strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
}

- (void)pan:(UIPanGestureRecognizer *)pan {
    CGPoint currentPoint = [pan locationInView:self];
    CGPoint midPoint = midpoint(previousPoint, currentPoint);
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        [mainPath moveToPoint:currentPoint];
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        [mainPath addQuadCurveToPoint:midPoint controlPoint:previousPoint];
    }
    
    previousPoint = currentPoint;
    
    [self setNeedsDisplay];
}


static CGPoint midpoint(CGPoint p0, CGPoint p1) {
    return (CGPoint) {
        (p0.x + p1.x) / 2.0,
        (p0.y + p1.y) / 2.0
    };
}

- (void)dealloc
{
    [mainPath release];
    [brush release];
    [super dealloc];
}

@end
