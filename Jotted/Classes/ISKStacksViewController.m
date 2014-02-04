//
//  ISKStacksViewController.m
//  Jotted
//
//  Created by linkov on 12/16/12.
//  Copyright (c) 2012 Alexey Linkov. All rights reserved.
//

#import "ISKStacksViewController.h"

static const NSUInteger kInitialAvailableNoteTag = 72;

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
    
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"kInitialAvailableNoteTagKey"]) {
        
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:kInitialAvailableNoteTag] forKey:@"kInitialAvailableNoteTagKey"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else {
        
        NSUInteger lastStackPage = [[[NSUserDefaults standardUserDefaults] valueForKey:@"kInitialAvailableNoteTagKey"] integerValue];
        NSUInteger initialAvaivablePage = kInitialAvailableNoteTag;
        NSUInteger numberOfPayedStacksAdded = (lastStackPage - initialAvaivablePage)/3;
        
        NSLog(@"lastStackPage = %i",lastStackPage);
        NSLog(@"initialAvaivablePage = %i",initialAvaivablePage);
        NSLog(@"number of stacks to add = %i",numberOfPayedStacksAdded);
        
        
        for (int k =1; k<=numberOfPayedStacksAdded; k++) {
            
            NSLog(@"add stack");
            
            NSMutableArray *stackPages = [NSMutableArray arrayWithCapacity:3];
            for (int i = initialAvaivablePage+1; i<=lastStackPage; i++) {
                [stackPages addObject:[NSString stringWithFormat:@"%i",i]];
                NSLog(@"add tag %i",i);
            }
             
        }
        

    }


    self.stacks =[NSMutableArray arrayWithObjects:simpleStack1,simpleStack2,simpleStack3, nil];
    self.activeStack = simpleStack1;
    
    
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
    
    
    _pageControl = [[StyledPageControl alloc]initWithFrame:CGRectMake(320/2-100/2, [[UIScreen mainScreen] bounds].size.height-32, 100, 13)];
    [self.view addSubview:self.pageControl];
    
    [self updatePageControl];
    
 //   [self addPayedStack];
    
}


-(void)addPayedStack {
    
    NSUInteger startTag =  [[[NSUserDefaults standardUserDefaults] valueForKey:@"kInitialAvailableNoteTagKey"] integerValue];
    
    NSString *first = [NSString stringWithFormat:@"%i",startTag+1];
    NSString *second = [NSString stringWithFormat:@"%i",startTag+2];
    NSString *third = [NSString stringWithFormat:@"%i",startTag+3];
    
    ISKSimpleStackViewController *stack = [[ISKSimpleStackViewController alloc]initWithTags:@[first,second,third] delegate:self];
    
    stack.view.frame =CGRectMake(320*self.stacks.count, 0, 320, [[UIScreen mainScreen] bounds].size.height);
    [self.pagingScrollView addSubview:stack.view];
    [stack animateUp];
    
    [self addChildViewController:stack];
    [stack didMoveToParentViewController:self];
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:startTag+3] forKey:@"kInitialAvailableNoteTagKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.stacks addObject:stack];
    [self updatePageControl];
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

-(void)updatePageControl {
    
    
    self.pagingScrollView.contentSize = CGSizeMake(PAGERPAGEWIDTH*self.stacks.count, [[UIScreen mainScreen] bounds].size.height);

    [self.pageControl setPageControlStyle:PageControlStyleDefault];
    self.pageControl.diameter = 6;
    
    self.pageControl.numberOfPages = self.stacks.count;
    self.pageControl.currentPage = 0;
    self.pageControl.alpha = 0;

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
    

    if (realPage<=self.stacks.count)   self.activeStack = self.stacks[realPage];

}


-(void)dealloc {
    
    [_activeStack release];
    [_pageControl release];
    [_pagingScrollView release];
    [super dealloc];
    
}


@end
