//
//  ISKGravityCollisionBehavior.h
//  Jotted
//
//  Created by linkov on 6/15/13.
//  Copyright (c) 2013 Alexey Linkov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ISKGravityCollisionBehavior : UIDynamicBehavior

-(instancetype)initWithItems:(NSArray*)items collisionDelegate:(id)delegate;

@end
