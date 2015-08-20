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

static const NSUInteger kInitialAvailableNoteTag = 72;

@interface ISKStacksViewController ()

@property  UIView *payView;
@property (strong) SKProduct *product;
@property (strong) NSString *buyText;

@end

@implementation ISKStacksViewController


- (UIBezierPath *)drawingPathForTag:(int)tag {

    NSString *docsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
	NSString *path = [docsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"textNoteDrawing_%i",tag]];

	NSData *bezierData = [NSData dataWithContentsOfFile:path];
    UIBezierPath *bezierPath = [NSKeyedUnarchiver unarchiveObjectWithData:bezierData];

    return bezierPath;
}


- (void)viewDidLoad {

    // setup paging scroll
    CGRect scrollFrame;
    scrollFrame.origin.x = 0;
    scrollFrame.origin.y = 0;
    scrollFrame.size.height =[[UIScreen mainScreen] bounds].size.height;
    scrollFrame.size.width = self.view.width;
    UIScrollView *sv = [[UIScrollView alloc]initWithFrame:scrollFrame];
    self.pagingScrollView =sv;

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

    if (IS_WIDESCREEN || IS_LEGACY_35 ) {



        ISKSimpleStackViewController *simpleStack2 = [[ISKSimpleStackViewController alloc]initWithTags:@[@"67",@"68",@"69"] delegate:self];
        [self addChildViewController:simpleStack2];
        [simpleStack2 didMoveToParentViewController:self];

        ISKSimpleStackViewController *simpleStack3 = [[ISKSimpleStackViewController alloc]initWithTags:@[@"70",@"71",@"72"] delegate:self];
        [self addChildViewController:simpleStack3];
        [simpleStack3 didMoveToParentViewController:self];

        self.stacks =[NSMutableArray arrayWithObjects:simpleStack1,simpleStack2,simpleStack3, nil];
    }
    else {
        self.stacks =[NSMutableArray arrayWithObjects:simpleStack1, nil];
    }


    self.activeStack = simpleStack1;

    int i = 0;
    for (ISKSimpleStackViewController *ss  in self.stacks) {

        ss.view.frame =CGRectMake(self.view.width*i, 0, self.view.width, [[UIScreen mainScreen] bounds].size.height);
        [self.pagingScrollView addSubview:ss.view];
        if (i>0) {
            [ss moveUp];
        }
        i++;
    }


    if (![self lastStackPage]) {

        [self setLastStackPage:kInitialAvailableNoteTag];
    }
    else {

        [self restorePurchasedStacks];
    }



    [self.view addSubview:self.pagingScrollView];

    [self addPurchaseScreen];


    _pageControl = [[SMPageControl alloc]initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height-22, self.view.width, 13)];
    [self.view addSubview:self.pageControl];

    [self updatePageControl];
    [self loadProducts];


     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];

    [self.activeStack loadActiveView];
    [self.activeStack enableTextView];


}

-(void)addStackWithTags:(NSArray *)tags {

    NSLog(@"tags = %@",tags);
    
    ISKSimpleStackViewController *stack = [[ISKSimpleStackViewController alloc]initWithTags:tags delegate:self];
    
    stack.view.frame =CGRectMake(self.view.width*self.stacks.count, 0, self.view.width, [[UIScreen mainScreen] bounds].size.height);
    [self.pagingScrollView addSubview:stack.view];
    
    [self addChildViewController:stack];
    [stack didMoveToParentViewController:self];
    [stack moveUp];
    
    [self.stacks addObject:stack];
    [self updatePageControl];
}

-(void)loadProducts {
    

}


-(void)beginIAP {
    
    [SVProgressHUD show];
    [[ISKStackIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            [SVProgressHUD dismiss];
            [[ISKStackIAPHelper sharedInstance] buyProduct:[products lastObject]];
            
        }else {
            
            [SVProgressHUD showErrorWithStatus:@"App Store is not available. Please try again in a minute"];
        }
    }];


}


- (NSUInteger)lastStackPage {
    PDKeychainBindings *wrapper=[PDKeychainBindings sharedKeychainBindings];
    NSString *valueString = [wrapper objectForKey:@"LastAvailableNoteTagKey"];
    int value = [valueString intValue];
    return value;
}

- (void)setLastStackPage:(NSUInteger)lastStackPage {
    PDKeychainBindings *wrapper=[PDKeychainBindings sharedKeychainBindings];
    NSString *valueString = [NSString stringWithFormat:@"%lu",(unsigned long)lastStackPage];
    [wrapper setObject:valueString forKey:@"LastAvailableNoteTagKey"];

}


-(void)restorePurchasedStacks {

        
        NSUInteger lastStackPage = [self lastStackPage];
        NSUInteger initialAvaivablePage = kInitialAvailableNoteTag;
        NSUInteger numberOfPayedStacksAdded = (lastStackPage - initialAvaivablePage)/3;

        for (int k =1; k<=numberOfPayedStacksAdded; k++) {
            
            NSMutableArray *stackPages = [NSMutableArray arrayWithCapacity:3];
            for (NSUInteger i = initialAvaivablePage+((k-1)*3)+1; i<=lastStackPage; i++) {
                [stackPages addObject:[NSNumber numberWithInteger:i]];
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
    
    NSString *first = [NSString stringWithFormat:@"%u",startTag+1];
    NSString *second = [NSString stringWithFormat:@"%u",startTag+2];
    NSString *third = [NSString stringWithFormat:@"%u",startTag+3];
    
    ISKSimpleStackViewController *stack = [[ISKSimpleStackViewController alloc]initWithTags:@[first,second,third] delegate:self];
    
    stack.view.frame =CGRectMake(self.view.width*self.stacks.count, 0, self.view.width, [[UIScreen mainScreen] bounds].size.height);
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
    self.pageControl.clipsToBounds = NO;
    self.activeStack = stack;
    
    [UIView animateWithDuration:0.4 animations:^{
        
        self.pageControl.alpha = 1;
    }];
 
    

}

-(void)updatePageControl {
    
    self.payView.frame =CGRectMake(self.view.width*self.stacks.count, 0, self.view.width, [[UIScreen mainScreen] bounds].size.height);
    
    self.pagingScrollView.contentSize = CGSizeMake(self.view.width*self.stacks.count+self.view.width, [[UIScreen mainScreen] bounds].size.height);

    self.pageControl.indicatorDiameter = 3;
    
    self.pageControl.numberOfPages = self.stacks.count+1;
    self.pageControl.currentPage = 0;
    self.pageControl.alpha = 0;

    
    [self.pageControl setImageMask:[UIImage imageNamed:@"lockMask"] forPage:self.stacks.count];
   
}

-(void)addPurchaseScreen {
    
    
    
    _payView = [[UIView alloc]initWithFrame:CGRectMake(self.view.width*self.stacks.count, 0, self.view.width, [[UIScreen mainScreen] bounds].size.height)];
    
    
    UIButton *buyButton= [[UIButton alloc]initWithFrame:CGRectMake(self.view.width/2-200/2, [[UIScreen mainScreen] bounds].size.height/2-200/2-100, 200, 200)];
    [buyButton setImage:[UIImage imageNamed:@"plus3"] forState:UIControlStateNormal];
    [buyButton addTarget:self action:@selector(beginIAP) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *buyLabel = [[UILabel alloc] initWithFrame:CGRectOffset(buyButton.frame, 0, 170)];
    
    
    buyLabel.font = [UIFont fontWithName:@"ArchitectsDaughter" size:22];
    buyLabel.numberOfLines = 0;
    buyLabel.textAlignment = NSTextAlignmentCenter;
    buyLabel.lineBreakMode = NSLineBreakByWordWrapping;
    buyLabel.textColor = UIColorFromRGB(0xB8E986);
    

    buyLabel.text =@"Get 3 additional notepads for JUST $0.99";
    self.buyText = buyLabel.text;

    
    [self.payView addSubview:buyButton];
    [self.payView addSubview:buyLabel];
    
    [self.pagingScrollView addSubview:self.payView];
    
 
}


#pragma mark - UIScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.pagingScrollView.frame.size.width;
    int page = floor((self.pagingScrollView.contentOffset.x - pageWidth / self.stacks.count) / pageWidth) + 1;


    int realPage;

    if (page<0) {

        realPage = 0;
    }
    else {
        realPage = page;
    }


    NSLog(@"real page - %i",realPage);
    if (realPage<=self.stacks.count-1)  {

        self.activeStack = self.stacks[realPage];
        [self.activeStack loadActiveView];
    }
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
            
    CGFloat pageWidth = self.pagingScrollView.frame.size.width;
    int page = floor((self.pagingScrollView.contentOffset.x - pageWidth / self.stacks.count) / pageWidth) + 1;
    self.pageControl.currentPage = page;

}


- (void)productPurchased:(NSNotification *)notification {
    
    [self addPayedStack];
}


-(void)dealloc {
     [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


@end
