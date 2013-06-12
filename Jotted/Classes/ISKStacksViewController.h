//
//  ISKStacksViewController.h
//  Jotted
//
//  Created by linkov on 12/16/12.
//  Copyright (c) 2012 Alexey Linkov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StyledPageControl.h"

@interface ISKStacksViewController : UIViewController <UIScrollViewDelegate>


@property (nonatomic,retain) StyledPageControl *pageControl;
@property (nonatomic,retain) UIScrollView *pagingScrollView;

@end
