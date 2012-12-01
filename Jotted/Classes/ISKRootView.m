//
//  ISKView.m
//  IndexStack
//
//  Created by Alexey Linkov on 9/2/12.
//  Copyright (c) 2012 Alexey Linkov. All rights reserved.
//

#import "ISKRootView.h"

@implementation ISKRootView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}



-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    // Allow these views to receive press events.  All other views will get ignored
    for( UIView *foundView in self.subviews )
    {
        if( foundView.tag == 66 ||foundView.tag == 65 )
        {
            return YES;
        }
    }
    return NO;
}


@end
