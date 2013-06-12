//
//  ISKDrawingView.m
//  IndexStack
//
//  Created by Alexey Linkov on 9/2/12.
//  Copyright (c) 2012 Alexey Linkov. All rights reserved.
//
#import "ISKDrawingView.h"


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

#pragma mark - Touch Methods
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
    [mainPath moveToPoint:[mytouch locationInView:self]];
    
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
    [mainPath addLineToPoint:[mytouch locationInView:self]];
    [self setNeedsDisplay];
    
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    
}

- (void)dealloc
{
    [mainPath release];
    [brush release];
    [super dealloc];
}

@end
