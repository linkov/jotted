//
//  ISKStacksViewController.m
//  Jotted
//
//  Created by linkov on 12/16/12.
//  Copyright (c) 2012 Alexey Linkov. All rights reserved.
//

#import "ISKStacksViewController.h"
#import "ISKSimpleStackViewController.h"
#import "ISKComplexStackViewController.h"

@interface ISKStacksViewController () {
    
    
    ISKSimpleStackViewController *simpleStack;
    ISKComplexStackViewController *complexStack;
    
}

@end

@implementation ISKStacksViewController
@synthesize pageControl,pagingScrollView;

-(void)loadView {
    
    //[self manageFirstLaunch];
    UIView *v = [UIView new];
    self.view = v;
    [v release];
    
    // setup paging scroll
    CGRect scrollFrame;
    scrollFrame.origin.x = 0;
    scrollFrame.origin.y = 0;
    scrollFrame.size.height =[[UIScreen mainScreen] bounds].size.height;
    scrollFrame.size.width = PAGERPAGEWIDTH;
    UIScrollView *sv = [[UIScrollView alloc]initWithFrame:scrollFrame];
    self.pagingScrollView =sv;
    [sv release];
    
    pagingScrollView.pagingEnabled = NO;
    pagingScrollView.scrollEnabled = NO;
    pagingScrollView.showsHorizontalScrollIndicator = NO;
    pagingScrollView.canCancelContentTouches = NO;
    pagingScrollView.directionalLockEnabled = YES;
    pagingScrollView.bounces = YES;
    pagingScrollView.delegate = self;
    pagingScrollView.contentSize = CGSizeMake(PAGERPAGEWIDTH*2, [[UIScreen mainScreen] bounds].size.height);
    pagingScrollView.backgroundColor = [UIColor blackColor];
    
    
    simpleStack = [[ISKSimpleStackViewController alloc]init];
    [self addChildViewController:simpleStack];
    [simpleStack didMoveToParentViewController:self];
    
    complexStack = [[ISKComplexStackViewController alloc]init];
    complexStack.isVisible = NO;
    [self addChildViewController:complexStack];
    [complexStack didMoveToParentViewController:self];
    
    
    [pagingScrollView addSubview:simpleStack.view];
    [pagingScrollView addSubview:complexStack.view];
    [self.view addSubview:pagingScrollView];
    
    [self setupPageControl];
    
    
    
}

-(void)setupPageControl {
    
    pageControl = [[StyledPageControl alloc]initWithFrame:CGRectMake(320/2-100/2, [[UIScreen mainScreen] bounds].size.height-32, 100, 13)];
    [pageControl setPageControlStyle:PageControlStyleDefault];
    pageControl.diameter = 6;
    
    pageControl.numberOfPages = 2;
    pageControl.currentPage = 0;
    pageControl.alpha = 0;
    [self.view addSubview:pageControl];
}


#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    

        
        // Update the page when more than 50% of the previous/next page is visible
        CGFloat pageWidth = pagingScrollView.frame.size.width;
        int page = floor((pagingScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        pageControl.currentPage = page;
    
    if (page == 1) {
        
        complexStack.isVisible = YES;
    }
    
}




@end
