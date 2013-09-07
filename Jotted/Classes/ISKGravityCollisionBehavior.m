//
//  ISKGravityCollisionBehavior.m
//  Jotted
//
//  Created by linkov on 6/15/13.
//  Copyright (c) 2013 Alexey Linkov. All rights reserved.
//

#import "ISKGravityCollisionBehavior.h"

@implementation ISKGravityCollisionBehavior


-(instancetype)initWithItems:(NSArray*)items collisionDelegate:(id)delegate {
    
    if (self=[super init]) {
        
        UIGravityBehavior *g = [[UIGravityBehavior alloc]initWithItems:items];
        UICollisionBehavior *c = [[UICollisionBehavior alloc]initWithItems:items];
        c.translatesReferenceBoundsIntoBoundary = YES;
        //g.yComponent = -0.1;
        [g setGravityDirection:CGVectorMake(0, -0.1)];
        c.collisionDelegate = delegate;
        c.collisionMode = UICollisionBehaviorModeBoundaries;
        [self addChildBehavior:g];
        [self addChildBehavior:c];
        [g release];
        [c release];
    }
    return self;
}

@end
