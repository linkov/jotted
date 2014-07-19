//
//  ISKStacksViewController.h
//  Jotted
//
//  Created by linkov on 12/16/12.
//  Copyright (c) 2012 Alexey Linkov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StyledPageControl.h"
#import "SMPageControl.h"
#import "ISKSimpleStackViewController.h"

@interface ISKStacksViewController : UIViewController <UIScrollViewDelegate>


@property (nonatomic,strong) SMPageControl *pageControl;
@property (nonatomic,strong) UIScrollView *pagingScrollView;
@property (nonatomic,strong) ISKSimpleStackViewController *activeStack;
@property (strong) NSMutableArray *stacks;

@end
