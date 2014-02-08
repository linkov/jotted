//
//  ISKStacksViewController.m
//  Jotted
//
//  Created by linkov on 12/16/12.
//  Copyright (c) 2012 Alexey Linkov. All rights reserved.
//

#import "ISKStacksViewController.h"
#import "ISKStackIAPHelper.h"
#import "PDKeychainBindings.h"
#import "SkyLab.h"
#import "TestFlight.h"

static const NSUInteger kInitialAvailableNoteTag = 72;

@interface ISKStacksViewController ()

@property  UIView *payView;
@property (retain) SKProduct *product;
@property (retain) NSString *buyText;

@end

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
    
    self.stacks =[NSMutableArray arrayWithObjects:simpleStack1,simpleStack2,simpleStack3, nil];

    
    if (![self lastStackPage]) {
        
        [self setLastStackPage:kInitialAvailableNoteTag];
    }
    else {
        
        [self restorePurchasedStacks];
    }
    

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
    
    [self addPurchaseScreen];

    
    _pageControl = [[StyledPageControl alloc]initWithFrame:CGRectMake(320/2-100/2, [[UIScreen mainScreen] bounds].size.height-32, 100, 13)];
    [self.view addSubview:self.pageControl];
    
    [self updatePageControl];
    
  //  [self addPayedStack];
    
    [self loadProducts];
    
}

-(void)addStackWithTags:(NSArray *)tags {

    NSLog(@"tags = %@",tags);
    
    ISKSimpleStackViewController *stack = [[ISKSimpleStackViewController alloc]initWithTags:tags delegate:self];
    
    stack.view.frame =CGRectMake(320*self.stacks.count, 0, 320, [[UIScreen mainScreen] bounds].size.height);
    [self.pagingScrollView addSubview:stack.view];
    
    [self addChildViewController:stack];
    [stack didMoveToParentViewController:self];
    
    [self.stacks addObject:stack];
    [self updatePageControl];
}

-(void)loadProducts {
    
    [[ISKStackIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            
            NSLog(@"products = %@",products);
            _product = [products lastObject];
            
            NSLog(@"self.product = %@",self.product);
        }
    }];
}


-(void)beginIAP {
    
    [self addPayedStack];
  //  [[ISKStackIAPHelper sharedInstance] buyProduct:self.product];
}


- (NSUInteger)lastStackPage {
    PDKeychainBindings *wrapper=[PDKeychainBindings sharedKeychainBindings];
    NSString *valueString = [wrapper objectForKey:@"LastAvailableNoteTagKey"];
    int value = [valueString intValue];
    return value;
}

- (void)setLastStackPage:(NSUInteger)lastStackPage {
    PDKeychainBindings *wrapper=[PDKeychainBindings sharedKeychainBindings];
    NSString *valueString = [NSString stringWithFormat:@"%i",lastStackPage];
    [wrapper setObject:valueString forKey:@"LastAvailableNoteTagKey"];

}


-(void)restorePurchasedStacks {

        
        NSUInteger lastStackPage = [self lastStackPage];
        NSUInteger initialAvaivablePage = kInitialAvailableNoteTag;
        NSUInteger numberOfPayedStacksAdded = (lastStackPage - initialAvaivablePage)/3;
        
        NSLog(@"lastStackPage = %i",lastStackPage);
        NSLog(@"initialAvaivablePage = %i",initialAvaivablePage);
        NSLog(@"number of stacks to add = %i",numberOfPayedStacksAdded);
        
        
        for (int k =1; k<=numberOfPayedStacksAdded; k++) {
            
            NSLog(@"add stack");
            
            NSMutableArray *stackPages = [NSMutableArray arrayWithCapacity:3];
            for (int i = initialAvaivablePage+((k-1)*3)+1; i<=lastStackPage; i++) {
                [stackPages addObject:[NSNumber numberWithInt:i]];
                NSLog(@"add tag %i",i);
                if (stackPages.count == 3) {
                    [self addStackWithTags:stackPages];
                    break;
                }
            }
            
            continue;
            
        }
        
        
}


-(void)addPayedStack {
    
    NSUInteger startTag = [self lastStackPage];
    
    NSString *first = [NSString stringWithFormat:@"%i",startTag+1];
    NSString *second = [NSString stringWithFormat:@"%i",startTag+2];
    NSString *third = [NSString stringWithFormat:@"%i",startTag+3];
    
    ISKSimpleStackViewController *stack = [[ISKSimpleStackViewController alloc]initWithTags:@[first,second,third] delegate:self];
    
    stack.view.frame =CGRectMake(320*self.stacks.count, 0, 320, [[UIScreen mainScreen] bounds].size.height);
    [self.pagingScrollView addSubview:stack.view];
    [stack animateUp];
    
    [self addChildViewController:stack];
    [stack didMoveToParentViewController:self];
    
    [self setLastStackPage:startTag+3];
    
    [self.stacks addObject:stack];
    [self updatePageControl];
    
    CGFloat pageWidth = self.pagingScrollView.frame.size.width;
    int page = floor((self.pagingScrollView.contentOffset.x - pageWidth / self.stacks.count) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    self.activeStack = stack;
    
    [UIView animateWithDuration:0.4 animations:^{
        
        self.pageControl.alpha = 1;
    }];
 
    

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
    
    self.payView.frame =CGRectMake(320*self.stacks.count, 0, 320, [[UIScreen mainScreen] bounds].size.height);
    
    self.pagingScrollView.contentSize = CGSizeMake(PAGERPAGEWIDTH*self.stacks.count+320, [[UIScreen mainScreen] bounds].size.height);

    [self.pageControl setPageControlStyle:PageControlStyleDefault];
    self.pageControl.diameter = 6;
    
    self.pageControl.numberOfPages = self.stacks.count;
    self.pageControl.currentPage = 0;
    self.pageControl.alpha = 0;

}

-(void)addPurchaseScreen {
    
    
    
    _payView = [[UIView alloc]initWithFrame:CGRectMake(320*self.stacks.count, 0, 320, [[UIScreen mainScreen] bounds].size.height)];
    
    
    UIButton *buyButton= [[UIButton alloc]initWithFrame:CGRectMake(320/2-200/2, [[UIScreen mainScreen] bounds].size.height/2-200/2-100, 200, 200)];
    [buyButton setImage:[UIImage imageNamed:@"plus3"] forState:UIControlStateNormal];
    [buyButton addTarget:self action:@selector(beginIAP) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *buyLabel = [[UILabel alloc] initWithFrame:CGRectOffset(buyButton.frame, 0, 170)];
    
    
    buyLabel.font = [UIFont fontWithName:@"ArchitectsDaughter" size:22];
    buyLabel.numberOfLines = 0;
    buyLabel.textAlignment = NSTextAlignmentCenter;
    buyLabel.lineBreakMode = NSLineBreakByWordWrapping;
    buyLabel.textColor = UIColorFromRGB(0xB8E986);
    
    [SkyLab abTestWithName:@"Buy text" A:^{
        
      buyLabel.text =@"Get 3 additional notepads for JUST $0.99";
        self.buyText = buyLabel.text;
        
        
    } B:^{
       buyLabel.text =@"More notepads for your notes and drawings";
        self.buyText = buyLabel.text;
    }];
    
    [self.payView addSubview:buyButton];
    [self.payView addSubview:buyLabel];
    [buyButton release];
    [buyLabel release];
    
    [self.pagingScrollView addSubview:self.payView];
    
 
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
    

    if (realPage<=self.stacks.count-1)   self.activeStack = self.stacks[realPage];

}

- (void)viewDidLoad {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
}


- (void)productPurchased:(NSNotification *)notification {
    
    [self addPayedStack];
    [TestFlight passCheckpoint:[NSString stringWithFormat:@"bought a stack with buy text [%@] ",self.buyText]];
}


-(void)dealloc {
     [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_activeStack release];
    [_pageControl release];
       [_payView release];
    [_pagingScrollView release];
    [_product release];
    [super dealloc];
    
}


@end
