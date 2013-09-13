//
//  ISKStacksViewController.m
//  Jotted
//
//  Created by linkov on 12/16/12.
//  Copyright (c) 2012 Alexey Linkov. All rights reserved.
//

#import "ISKStacksViewController.h"


@implementation ISKStacksViewController

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
    
    self.pagingScrollView.pagingEnabled = NO;
    self.pagingScrollView.scrollEnabled = NO;
    self.pagingScrollView.showsHorizontalScrollIndicator = NO;
    self.pagingScrollView.canCancelContentTouches = NO;
    self.pagingScrollView.directionalLockEnabled = YES;
    self.pagingScrollView.bounces = YES;
    self.pagingScrollView.delegate = self;

    self.pagingScrollView.backgroundColor = [UIColor blackColor];
    

    
    ISKSimpleStackViewController *simpleStack1 = [[ISKSimpleStackViewController alloc]initWithTags:@[@"64",@"65",@"66"] delegate:self];
    [self addChildViewController:simpleStack1];
    [simpleStack1 didMoveToParentViewController:self];
    
    ISKSimpleStackViewController *simpleStack2 = [[ISKSimpleStackViewController alloc]initWithTags:@[@"67",@"68",@"69"] delegate:self];
    [self addChildViewController:simpleStack2];
    [simpleStack2 didMoveToParentViewController:self];
    
    ISKSimpleStackViewController *simpleStack3 = [[ISKSimpleStackViewController alloc]initWithTags:@[@"70",@"71",@"72"] delegate:self];
    [self addChildViewController:simpleStack3];
    [simpleStack3 didMoveToParentViewController:self];
    
    self.stacks = @[simpleStack1,simpleStack2,simpleStack3];
    self.activeStack = simpleStack1;
    
    self.pagingScrollView.contentSize = CGSizeMake(PAGERPAGEWIDTH*self.stacks.count, [[UIScreen mainScreen] bounds].size.height);
    
    int i = 0;
    for (ISKSimpleStackViewController *ss  in self.stacks) {
        
        ss.view.frame =CGRectMake(320*i, 0, 320, [[UIScreen mainScreen] bounds].size.height);
        [self.pagingScrollView addSubview:ss.view];
        if (i>0) {
            [ss animateUp];
        }
        i++;
    }
    
    [self.view addSubview:self.pagingScrollView];
    
    [self setupPageControl];
    
    
    
}

//-(void)viewDidLoad {
//    
//    // List all fonts on iPhone
//    NSArray *familyNames = [[NSArray alloc] initWithArray:[UIFont familyNames]];
//    NSArray *fontNames;
//    NSInteger indFamily, indFont;
//    for (indFamily=0; indFamily<[familyNames count]; ++indFamily)
//    {
//        NSLog(@"Family name: %@", [familyNames objectAtIndex:indFamily]);
//        fontNames = [[NSArray alloc] initWithArray:
//                     [UIFont fontNamesForFamilyName:
//                      [familyNames objectAtIndex:indFamily]]];
//        for (indFont=0; indFont<[fontNames count]; ++indFont)
//        {
//            NSLog(@"    Font name: %@", [fontNames objectAtIndex:indFont]);
//        }
//        fontNames = nil;
//    }
//    familyNames = nil;
//
//}

-(void)setupPageControl {
    
    _pageControl = [[StyledPageControl alloc]initWithFrame:CGRectMake(320/2-100/2, [[UIScreen mainScreen] bounds].size.height-32, 100, 13)];
    [self.pageControl setPageControlStyle:PageControlStyleDefault];
    self.pageControl.diameter = 6;
    
    self.pageControl.numberOfPages = self.stacks.count;
    self.pageControl.currentPage = 0;
    self.pageControl.alpha = 0;
    [self.view addSubview:self.pageControl];
}


#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
            
        // Update the page when more than 50% of the previous/next page is visible
        CGFloat pageWidth = self.pagingScrollView.frame.size.width;
        int page = floor((self.pagingScrollView.contentOffset.x - pageWidth / self.stacks.count) / pageWidth) + 1;
        self.pageControl.currentPage = page;

    
    int realPage;
    
    if (page<0) {
        
        realPage = 0;
    }
    else {
        realPage = page;
    }
    
       self.activeStack = self.stacks[realPage];
    NSLog(@"ACTIVE STACK = %@",self.activeStack);
//
//    if (page == 1) {
//        
//        complexStack.isVisible = YES;
//    }
    
}


-(void)dealloc {
    
    [_activeStack release];
    [_pageControl release];
    [_pagingScrollView release];
    [super dealloc];
    
}


@end
