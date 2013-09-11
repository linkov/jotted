//
//  UIView+XYWHChange.m
//  CConsumers
//
//  Created by Alexey Linkov on 7/12/12.
//  Copyright (c) 2012 SDWR. All rights reserved.
//

#import "UIView+XYWHChange.h"

@implementation UIView (XYWHChange)


-(void) setHeight:(CGFloat)height {
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
}

-(CGFloat) height {
    
    return self.frame.size.height;
}


-(void) setWidth:(CGFloat)width {
    
     self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, self.frame.size.height);
}

-(CGFloat) width {
    
    return self.frame.size.width;
}



-(void) setX:(CGFloat)x {
    
    self.frame = CGRectMake(x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

-(CGFloat) x {
    
    return self.frame.origin.x;
}


-(void) setY:(CGFloat)y {
    
    self.frame = CGRectMake(self.frame.origin.x, y, self.frame.size.width, self.frame.size.height);
}

-(CGFloat) y {
    
    return self.frame.origin.y;
}


@end
