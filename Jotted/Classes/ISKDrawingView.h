//
//  ISKDrawingView.h
//  IndexStack
//
//  Created by Alexey Linkov on 9/2/12.
//  Copyright (c) 2012 Alexey Linkov. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ISKDrawingView : UIView

@property (nonatomic,strong)UIBezierPath *mainPath;
@property (nonatomic,strong) UIColor *brush;

@end
