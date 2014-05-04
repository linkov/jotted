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


@property (nonatomic,retain) SMPageControl *pageControl;
@property (nonatomic,retain) UIScrollView *pagingScrollView;
@property (nonatomic,retain) ISKSimpleStackViewController *activeStack;
@property (retain) NSMutableArray *stacks;

@end
