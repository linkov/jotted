//
//  ISKTiltRevealMotionEffect.m
//  Jotted
//
//  Created by linkov on 6/14/13.
//  Copyright (c) 2013 Alexey Linkov. All rights reserved.
//

#import "ISKTiltRevealMotionEffect.h"

@implementation ISKTiltRevealMotionEffect

- (NSDictionary *)keyPathsAndRelativeValuesForViewerOffset:(UIOffset)viewerOffset {
    
    NSLog(@"horizontal %f",viewerOffset.horizontal);
    NSLog(@"vertical %f",viewerOffset.vertical);
    
    float alphaOffset;
    
    if (viewerOffset.horizontal > 0.2) {
        
        alphaOffset = -viewerOffset.horizontal*2;
    }
    else {
        alphaOffset = viewerOffset.horizontal*2;
    }
    
    
    NSDictionary* dict = @{
                           //@"center" : [NSValue valueWithCGPoint:CGPointMake(3.4, 1.2)],
                           @"alpha" : [NSNumber numberWithFloat:alphaOffset]
                           };
    
    return dict;
}

@end
