//
//  ISKComplexStackViewController.m
//  Jotted
//
//  Created by linkov on 12/16/12.
//  Copyright (c) 2012 Alexey Linkov. All rights reserved.
//




#define TRANSITION_Y_AXIS 88
#define TRANSFORM_WH 25

#import "ISKNoteView.h"
#import "ISKComplexStackViewController.h"
#import "ISKStacksViewController.h"


@interface ISKComplexStackViewController () {
    
    ISKStacksViewController *parent;
    //UIScrollView *pagingScrollView;
    //StyledPageControl* pageControl;
    
    UISwipeGestureRecognizer *clearGR;
    UISwipeGestureRecognizer *flipGR;
    UISwipeGestureRecognizer *revealGR;
    UISwipeGestureRecognizer *hideGR;
    UITapGestureRecognizer *switchViewGR;
    UITapGestureRecognizer *switchViewGR2;
    
    
    ISKNoteView *firstView;
    ISKNoteView *secondView;
    ISKNoteView *thirdView;
    
    UIView *overlay;
    
    UIImageView *pencil;
    UIImageView *upArrow;
    UIImageView *downArrow;
    UITextView *noteText;
    UIButton *doneButton;
    
    int activeView;
    
    BOOL keyboardShown;
    CGSize keyboardSize;
}

-(void)toggleArrows:(UIScrollView*)scroll;
-(void)finishEdit;
-(void)manageFirstLaunch;
-(void)clearNote;
-(void)switchToView:(UIGestureRecognizer*)gr;
-(void)checkDrawings;
-(void)animateUp;
-(void)animateDown;
-(void)updateAppSettings;
-(void)showFlipside;

-(void)keyboardWasHidden:(NSNotification*)aNotification;
-(void)keyboardWasShown:(NSNotification*)aNotification;

@end

@implementation ISKComplexStackViewController
@synthesize complexNotepadStack;

-(void)loadView
{
    
    self.view = [[[UIView alloc]initWithFrame:CGRectMake(320, 0, 320, [[UIScreen mainScreen] bounds].size.height-20)]autorelease];
    parent = (ISKStacksViewController*)self.parentViewController;
    
    self.complexNotepadStack = [[ISKRootView alloc]initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    //complexNotepadStack.backgroundColor = [UIColor greenColor];
    
    
    
    flipGR = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(showFlipside)];
    flipGR.direction = UISwipeGestureRecognizerDirectionLeft;
    
    clearGR = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(clearNote)];
    clearGR.direction = UISwipeGestureRecognizerDirectionRight;
    
    revealGR = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(animateUp)];
    revealGR.direction = UISwipeGestureRecognizerDirectionUp;
    
    hideGR = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(animateDown)];
    hideGR.direction = UISwipeGestureRecognizerDirectionDown;
    hideGR.enabled = NO;
    
    switchViewGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(switchToView:)];
    switchViewGR.numberOfTapsRequired = 1;
    
    switchViewGR2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(switchToView:)];
    switchViewGR2.numberOfTapsRequired = 1;
    
    [complexNotepadStack addGestureRecognizer:clearGR];
    [complexNotepadStack addGestureRecognizer:flipGR];
    [complexNotepadStack addGestureRecognizer:revealGR];
    [self.view addGestureRecognizer:hideGR];
    [clearGR release];
    [flipGR release];
    [revealGR release];
    [hideGR release];
    
    
    firstView = [[ISKNoteView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    firstView.backgroundColor = CREMECOLOR;
    firstView.tag = 67;
    
    secondView = [[ISKNoteView alloc]initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height)];
    secondView.backgroundColor = GRASSCOLOR;
    secondView.alpha = 0;
    secondView.tag = 68;
    
    thirdView = [[ISKNoteView alloc]initWithFrame:CGRectMake(0, 88, self.view.frame.size.width, self.view.frame.size.height)];
    thirdView.backgroundColor = WHITECOLOR;
    thirdView.alpha = 0;
    thirdView.tag = 69;
    
    [secondView addGestureRecognizer:switchViewGR];
    [thirdView addGestureRecognizer:switchViewGR2];
    [switchViewGR release];
    [switchViewGR2 release];
    
    // pagingScrollView = parent.pagingScrollView;
    //pageControl = parent.pageControl;
    
    // setup paging scroll
    //    CGRect scrollFrame;
    //    scrollFrame.origin.x = 0;
    //    scrollFrame.origin.y = 0;
    //    scrollFrame.size.height = 480;
    //    scrollFrame.size.width = PAGERPAGEWIDTH;
    //
    //    pagingScrollView = [[UIScrollView alloc]initWithFrame:scrollFrame];
    //    pagingScrollView.pagingEnabled = NO;
    //    pagingScrollView.scrollEnabled = NO;
    //    pagingScrollView.canCancelContentTouches = NO;
    //    pagingScrollView.directionalLockEnabled = YES;
    //    pagingScrollView.bounces = YES;
    //    pagingScrollView.delegate = self;
    //    pagingScrollView.contentSize = CGSizeMake(PAGERPAGEWIDTH*2, 480);
    //    pagingScrollView.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    
    // UIView *checklistNotepadStack = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x+PAGERPAGEWIDTH, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    
    [complexNotepadStack addSubview:firstView];
    [complexNotepadStack insertSubview:secondView belowSubview:firstView];
    [complexNotepadStack insertSubview:thirdView belowSubview:secondView];
    
    //[pagingScrollView  addSubview:complexNotepadStack];
    // [pagingScrollView addSubview:checklistNotepadStack];
    [self.view addSubview:complexNotepadStack];
    
    
    
    [firstView release];
    [secondView release];
    [thirdView release];
    
    noteText = [[UITextView alloc]initWithFrame:CGRectMake(10, 55, 300, [[UIScreen mainScreen] bounds].size.height-20-(40+55)+2-15 )];
    noteText.autocorrectionType  = UITextAutocorrectionTypeNo;
    noteText.backgroundColor = [UIColor clearColor];
    //noteText.
    
    noteText.delegate = self;
    [complexNotepadStack addSubview:noteText];
    [noteText release];
    
    doneButton = [[UIButton alloc]initWithFrame:CGRectMake(255, 10, 55, 44)];
    doneButton.layer.cornerRadius = STACKCORNERRAD;
    doneButton.layer.borderWidth = 1;
    doneButton.layer.borderColor = [UIColorFromRGB(0xF6F6F6) CGColor];
    [doneButton setTitle:@"done" forState:UIControlStateNormal];
    [doneButton setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
    doneButton.backgroundColor = UIColorFromRGB(0xE8E8E8);
    [doneButton addTarget:self action:@selector(finishEdit) forControlEvents:UIControlEventTouchUpInside];
    doneButton.alpha = 0;
    [complexNotepadStack addSubview:doneButton];
    [doneButton release];
    
    activeView = 67;
    
    noteText.text =  [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"textNote_%i",activeView]];
    
    
    upArrow = [[UIImageView alloc]initWithFrame:CGRectMake(320/2-9/2, 40, 9, 6)];
    upArrow.image = [UIImage imageNamed:@"blackArrowUp"];
    upArrow.alpha = 0;
    
    [complexNotepadStack addSubview:upArrow];
    [upArrow release];
    
    downArrow = [[UIImageView alloc]initWithFrame:CGRectMake(320/2-9/2, noteText.frame.size.height+65, 9, 6)];
    downArrow.image = [UIImage imageNamed:@"blackArrowDown"];
    downArrow.alpha = 0;
    
    [complexNotepadStack addSubview:downArrow];
    [downArrow release];
    
    [self toggleArrows:noteText];
    
    pencil = [[UIImageView alloc]initWithFrame:CGRectMake(320/2-7, 15, 15, 15)];
    pencil.image = [UIImage imageNamed:@"blackPencil"];
    pencil.alpha = 0;
    
    [complexNotepadStack addSubview:pencil];
    [pencil release];
    
    [self manageFirstLaunch];
    
    [self updateAppSettings];
    
    [self checkDrawings];
    
    [self toggleArrows:noteText];
    
    [self setupOverlay];
    
    [self animateUp];
   
    //[self setupPageControl];
    
    CGSize paddedSize = CGSizeMake(noteText.contentSize.width, noteText.contentSize.height-10);
    noteText.contentSize = paddedSize;
    noteText.contentInset = UIEdgeInsetsMake(-16, 0, 0, 0);
    //noteText.contentOffset = CGPointMake(0, 18);
}


-(void)finishEdit {
    
    [noteText resignFirstResponder];
}


-(void)manageFirstLaunch {
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        
        noteText.text = @"Swipe up to reveal all notes\nYou can doole on the flip side of a note\nYou can clean flip side with 2 finger tap\nSwipe left to flip this note\nSwipe right to delete this text\n";
        
        [[NSUserDefaults standardUserDefaults] setValue:noteText.text forKey:[NSString stringWithFormat:@"textNote_%i",activeView]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
}


-(void)clearNote {
    
    if (noteText.text.length >0) {
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Clear all text?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Clear",nil];
        [alert show];
        [alert release];
    }
    
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex != 0) {
        noteText.text = @"";
        [[NSUserDefaults standardUserDefaults] setValue:noteText.text forKey:[NSString stringWithFormat:@"textNote_%i",activeView]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self toggleArrows:noteText];
	}
}


-(void)switchToView:(UIGestureRecognizer*)gr{
    
    
    
    downArrow.alpha = 0;
    upArrow.alpha = 0;
    
    [self animateDown];
    
    UIColor *toColor = gr.view.backgroundColor;
    UIColor *fromColor = firstView.backgroundColor;
    
    
    firstView.backgroundColor = toColor;
    gr.view.backgroundColor = fromColor;
    
    if ([firstView.backgroundColor isEqual: CREMECOLOR]) {
        activeView = 67;
    }
    else if ([firstView.backgroundColor isEqual:GRASSCOLOR ]) {
        
        activeView = 68;
    }
    else if ([firstView.backgroundColor isEqual: WHITECOLOR]) {
        activeView = 69;
    }
    
    noteText.text =  [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"textNote_%i",activeView]];
    CGSize paddedSize = CGSizeMake(noteText.contentSize.width, noteText.contentSize.height-10);
    noteText.contentSize = paddedSize;
    
    [self toggleArrows:noteText];
    
    [self checkDrawings];
    
    
}


-(void)checkDrawings {
    
    NSString * docsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString * path = [docsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"textNoteDrawing_%i",activeView]];
    
    
    NSData *bezierData = [NSData dataWithContentsOfFile:path];
    
    if (bezierData) {
        
        UIBezierPath *bezierPath = [NSKeyedUnarchiver unarchiveObjectWithData:bezierData];
        if (bezierPath) {
            
            if ((bezierPath.bounds.size.width == 0 && bezierPath.bounds.size.height == 0) || bezierPath.isEmpty ) {
                
                pencil.alpha = 0;
            }
            else {
                pencil.alpha = 0.6;
            }
        }
        else {
            pencil.alpha = 0;
        }
        
    }
    else {
        pencil.alpha = 0;
    }
}

-(void)squeezeStack {
    
    
    for (ISKNoteView *v  in complexNotepadStack.subviews) {
        
        if (![v.class isSubclassOfClass:[UIImageView class]] && ![v.class isSubclassOfClass:[UIControl class]]) {
            
            CGRect newFrame = v.frame;
            newFrame.size.height -= TRANSFORM_WH;
            newFrame.size.width -= TRANSFORM_WH;
            newFrame.origin.x +=TRANSFORM_WH/2;
            newFrame.origin.y +=TRANSFORM_WH/2;
            v.frame = newFrame;
//            if (![v.class isSubclassOfClass:[UITextView class]]) {
//                [v.layer setMasksToBounds:NO ];
//                [v.layer setShadowColor:[[UIColor blackColor ] CGColor ] ];
//                [v.layer setShadowOpacity:0.65 ];
//                [v.layer setShadowRadius:6.0 ];
//                [v.layer setShadowOffset:CGSizeMake( 0 , 0 ) ];
//                [v.layer setShouldRasterize:YES ];
//            }
            
            
        }
        
        
    }
    
}

-(void)expandStack {
    
    for (ISKNoteView *v  in complexNotepadStack.subviews) {
        
        if (![v.class isSubclassOfClass:[UIImageView class]] && ![v.class isSubclassOfClass:[UIControl class]]) {
            
            CGRect newFrame = v.frame;
            newFrame.size.height += TRANSFORM_WH;
            newFrame.size.width += TRANSFORM_WH;
            newFrame.origin.x -=TRANSFORM_WH/2;
            newFrame.origin.y -=TRANSFORM_WH/2;
            v.frame = newFrame;
            
            //[v.layer setShadowOpacity:0];
        }
    }
    
}

-(void)animateUp  {
    
    
    [UIView animateWithDuration:0.2 animations:^{
        
        CGPoint p = complexNotepadStack.center;
        p.y -= TRANSITION_Y_AXIS;
        complexNotepadStack.center = p;
        secondView.alpha = 1;
        thirdView.alpha = 1;
        [self squeezeStack];
        [self addOverlay];
        
    } completion:^(BOOL finished) {
        
        clearGR.enabled = NO;
        flipGR.enabled= NO;
        revealGR.enabled = NO;
        hideGR.enabled = YES;
        noteText.editable = NO;
        noteText.userInteractionEnabled = NO;
        
        if (self.isVisible) {
            parent.pageControl.alpha =1;
            parent.pagingScrollView.pagingEnabled = YES;
            parent.pagingScrollView.scrollEnabled = YES;
        }
        
    }];
    
    
}


-(void)animateDown  {
    
    parent.pageControl.alpha = 0;
    
    [UIView animateWithDuration:0.2 animations:^{
        
        CGPoint p = complexNotepadStack.center;
        p.y += TRANSITION_Y_AXIS;
        complexNotepadStack.center = p;
        secondView.alpha = 0;
        thirdView.alpha = 0;
        [self expandStack];
        [self hideOverlay];
        
        
    } completion:^(BOOL finished) {
        
        parent.pagingScrollView.pagingEnabled = NO;
        parent.pagingScrollView.scrollEnabled = NO;
        flipGR.enabled= YES;
        revealGR.enabled = YES;
        clearGR.enabled = YES;
        hideGR.enabled = NO;
        
        noteText.editable = YES;
        noteText.userInteractionEnabled = YES;
        
        
        
    }];
    
}


-(void)setupOverlay{
    
    overlay = [[UIView alloc]initWithFrame:self.view.frame];
    overlay.alpha = 0;
    overlay.backgroundColor = [UIColor blackColor];
    [overlay setUserInteractionEnabled: NO];
    //overlay.backgroundColor = [UIColor blackColor];
    [self.view addSubview:overlay];
    
    
}


-(void)addOverlay {
    
    overlay.alpha = 0.3;
}

-(void)hideOverlay {
    
    overlay.alpha = 0;
}

-(void)setupPageControl {
    
    //    pageControl = [[StyledPageControl alloc]initWithFrame:CGRectMake(320/2-100/2, 448, 100, 13)];
    //    [pageControl setPageControlStyle:PageControlStyleDefault];
    //    pageControl.diameter = 6;
    //
    //    pageControl.numberOfPages = 2;
    //    pageControl.currentPage = 0;
    //    pageControl.alpha = 0;
    //    [self.view addSubview:pageControl];
    
    
}


-(void)updateAppSettings  {
    
    BOOL blackInk = [[NSUserDefaults standardUserDefaults] boolForKey:@"enableBlueInk"];
    
    if (blackInk == YES) {
        
        noteText.textColor = UIColorFromRGB(0x102855);
    }
    else {
        
        noteText.textColor = [UIColor blackColor];
    }
    
    
    
    
    BOOL smallFont = [[NSUserDefaults standardUserDefaults] boolForKey:@"enableSmallerFont"];
    
    if (smallFont == YES) {
        
        noteText.font = [UIFont fontWithName:@"Noteworthy-Light" size:20];
        
    }
    else {
        
        noteText.font = [UIFont fontWithName:@"Noteworthy-Light" size:24];
        
    }
    
    
    CGSize paddedSize = CGSizeMake(noteText.contentSize.width, noteText.contentSize.height-10);
    noteText.contentSize = paddedSize;
    [self toggleArrows:noteText];
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    keyboardShown = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasHidden:)
                                                 name:UIKeyboardDidHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateAppSettings)
                                                 name:NSUserDefaultsDidChangeNotification
                                               object:nil];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
}




//-(void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
//
//    CGSize paddedSize = CGSizeMake(scrollView.contentSize.width, scrollView.contentSize.height-18);
//    scrollView.contentSize = paddedSize;
//}


-(void)toggleArrows:(UIScrollView*)scroll {
    
    
    
    if (scroll.contentOffset.y >18) {
        
        upArrow.alpha = 1;
    }
    else {
        upArrow.alpha = 0;
    }
    
    if ( (scroll.contentOffset.y+scroll.frame.size.height < scroll.contentSize.height)) {
        
        downArrow.alpha = 1;
        
        
        
    }
    else {
        
        downArrow.alpha = 0;
        
    }
    
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    flipGR.enabled= NO;
    revealGR.enabled = NO;
    clearGR.enabled = NO;
    doneButton.alpha = 0.7;
    downArrow.alpha = 0;
    return YES;
    
}

- (void)textViewDidEndEditing:(UITextView *)tView {
    
    flipGR.enabled= YES;
    revealGR.enabled = YES;
    clearGR.enabled = YES;
    doneButton.alpha = 0;
    
    downArrow.alpha = 0;
    upArrow.alpha = 0;
    
    [[NSUserDefaults standardUserDefaults] setValue:tView.text forKey:[NSString stringWithFormat:@"textNote_%i",activeView]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    
    // [self toggleArrows:tView];
    
}


//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
//{
//    if ( [text isEqualToString:@"\n"] ) {
//        NSLog(@"rr");
//        NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:textView.text];
//        [string addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,5)];
//        textView.attributedText = string;
//    }
//    return YES;
//}


-(void)keyboardWasShown:(NSNotification*)aNotification {
    if(keyboardShown) {
        return;
    }
    
    NSDictionary *info = [aNotification userInfo];
    
    // Get the size of the keyboard.
    NSValue *aValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    keyboardSize = [aValue CGRectValue].size;
    
    // Resize the scroll view (which is the root view of the window)
    CGRect viewFrame = [noteText frame];
    
    viewFrame.size.height -= keyboardSize.height-42+2;
    
    noteText.frame = viewFrame;
    
    
    // Scroll the active text field into view.
    //CGRect textFieldRect = [activeField frame];
    [noteText scrollRectToVisible:viewFrame animated:YES];
    
    keyboardShown = YES;
    
}

-(void)keyboardWasHidden:(NSNotification*)aNotification {
    if(!keyboardShown) {
        return;
    }
    
    // Reset the height of the scroll view to its original value
    CGRect viewFrame = [noteText frame];
    
    viewFrame.size.height += keyboardSize.height-42+2;
    
    noteText.frame = viewFrame;
    
    keyboardShown = NO;
    CGSize paddedSize = CGSizeMake(noteText.contentSize.width, noteText.contentSize.height-10);
    noteText.contentSize = paddedSize;
    
    [self toggleArrows:noteText];
    
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ([scrollView.superview isKindOfClass:[UITextView class]]) {
        
        [self toggleArrows:scrollView];
        
    }
    //    else {
    //
    //        // Update the page when more than 50% of the previous/next page is visible
    //        CGFloat pageWidth = pagingScrollView.frame.size.width;
    //        int page = floor((pagingScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    //        pageControl.currentPage = page;
    //
    //
    //    }
    
    
}

#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinishWithView:(int)aView
{
    [self dismissModalViewControllerAnimated:YES];
    activeView = aView;
    
    [self checkDrawings];
}

- (void)showFlipside
{
    ISKFlipsideViewController *controller = [ISKFlipsideViewController new];
    controller.delegate = self;
    controller.activeNote = activeView;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:controller animated:YES];
    [controller release];
}

-(void)dealloc {
    
    [pencil release];
    [clearGR release];
    [flipGR release];
    [revealGR release];
    [hideGR release];
    [switchViewGR release];
    [switchViewGR2 release];
    [upArrow release];
    [downArrow release];
    [firstView release];
    [secondView release];
    [thirdView release];
    
    [noteText release];
    [doneButton release];
    
    [super dealloc];
}

@end
