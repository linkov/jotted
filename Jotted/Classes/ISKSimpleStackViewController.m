//
//  ISKMainViewController.m
//  IndexStack
//
//  Created by Alexey Linkov on 9/1/12.
//  Copyright (c) 2012 Alexey Linkov. All rights reserved.
//

#define TRANSITION_Y_AXIS 88
#define TRANSFORM_WH 25

#include "ISKNoteView.h"
#import "ISKSimpleStackViewController.h"
#import "ISKRootView.h"

@interface ISKSimpleStackViewController () {
    
    UIScrollView *pagingScrollView;
    
    UISwipeGestureRecognizer *clearGR;
    UISwipeGestureRecognizer *flipGR;
    UISwipeGestureRecognizer *revealGR;
    UISwipeGestureRecognizer *hideGR;
    UITapGestureRecognizer *switchViewGR;
    UITapGestureRecognizer *switchViewGR2;
    
    ISKRootView *simpleNotepadStack;
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

@implementation ISKSimpleStackViewController

-(void)loadView
{
    
    self.view = [[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height-20)]autorelease];
    
    
    simpleNotepadStack = [[ISKRootView alloc]initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    //simpleNotepadStack.backgroundColor = [UIColor greenColor];
    
    
    
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
    
    [simpleNotepadStack addGestureRecognizer:clearGR];
    [simpleNotepadStack addGestureRecognizer:flipGR];
    [simpleNotepadStack addGestureRecognizer:revealGR];
    [self.view addGestureRecognizer:hideGR];
    [clearGR release];
    [flipGR release];
    [revealGR release];
    [hideGR release];
    
    
    firstView = [[ISKNoteView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    firstView.backgroundColor = YELLOWCOLOR;
    firstView.tag = 64;
    
    secondView = [[ISKNoteView alloc]initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height)];
    secondView.backgroundColor = BLUECOLOR;
    secondView.alpha = 0;
    secondView.tag = 65;
    
    thirdView = [[ISKNoteView alloc]initWithFrame:CGRectMake(0, 88, self.view.frame.size.width, self.view.frame.size.height)];
    thirdView.backgroundColor = REDCOLOR;
    thirdView.alpha = 0;
    thirdView.tag = 66;
    
    [secondView addGestureRecognizer:switchViewGR];
    [thirdView addGestureRecognizer:switchViewGR2];
    [switchViewGR release];
    [switchViewGR2 release];
    
    
    // setup paging scroll
    CGRect scrollFrame;
    scrollFrame.origin.x = 0;
    scrollFrame.origin.y = 0;
    scrollFrame.size.height = 480;
    scrollFrame.size.width = PAGERPAGEWIDTH;
    
    pagingScrollView = [[UIScrollView alloc]initWithFrame:scrollFrame];
    pagingScrollView.pagingEnabled = NO;
    pagingScrollView.scrollEnabled = NO;
    pagingScrollView.canCancelContentTouches = NO;
    pagingScrollView.directionalLockEnabled = YES;
    pagingScrollView.bounces = YES;
    pagingScrollView.delegate = self;
    pagingScrollView.contentSize = CGSizeMake(PAGERPAGEWIDTH*2, 480);
    pagingScrollView.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    
   // UIView *checklistNotepadStack = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x+PAGERPAGEWIDTH, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    
    [simpleNotepadStack addSubview:firstView];
    [simpleNotepadStack insertSubview:secondView belowSubview:firstView];
    [simpleNotepadStack insertSubview:thirdView belowSubview:secondView];
    
    [pagingScrollView  addSubview:simpleNotepadStack];
   // [pagingScrollView addSubview:checklistNotepadStack];
    [self.view addSubview:pagingScrollView];
    
    
    
    [firstView release];
    [secondView release];
    [thirdView release];
    
    noteText = [[UITextView alloc]initWithFrame:CGRectMake(10, 55, 300, [[UIScreen mainScreen] bounds].size.height-20-(40+55)+2-15 )];
    noteText.autocorrectionType  = UITextAutocorrectionTypeNo;
    noteText.backgroundColor = [UIColor clearColor];
    //noteText.
    
    noteText.delegate = self;
    [simpleNotepadStack addSubview:noteText];
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
    [self.view addSubview:doneButton];
    [doneButton release];
    
    activeView = 64;
    
    noteText.text =  [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"textNote_%i",activeView]];

    
    upArrow = [[UIImageView alloc]initWithFrame:CGRectMake(320/2-9/2, 40, 9, 6)];
    upArrow.image = [UIImage imageNamed:@"blackArrowUp"];
    upArrow.alpha = 0;
    
    [self.view addSubview:upArrow];
    [upArrow release];
    
    downArrow = [[UIImageView alloc]initWithFrame:CGRectMake(320/2-9/2, noteText.frame.size.height+65, 9, 6)];
    downArrow.image = [UIImage imageNamed:@"blackArrowDown"];
    downArrow.alpha = 0;
    
    [self.view addSubview:downArrow];
    [downArrow release];
    
    [self toggleArrows:noteText];
    
    pencil = [[UIImageView alloc]initWithFrame:CGRectMake(320/2-7, 15, 15, 15)];
    pencil.image = [UIImage imageNamed:@"blackPencil"];
    pencil.alpha = 0;
    
    [self.view addSubview:pencil];
    [pencil release];
    
    [self manageFirstLaunch];
    
    [self updateAppSettings];
    
    [self checkDrawings];
    
    [self toggleArrows:noteText];
    
    [self setupShadow];
    
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
    
    if ([firstView.backgroundColor isEqual: YELLOWCOLOR]) {
        activeView = 64;
    }
    else if ([firstView.backgroundColor isEqual:BLUECOLOR ]) {
        
        activeView = 65;
    }
    else if ([firstView.backgroundColor isEqual: REDCOLOR]) {
        activeView = 66;
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
    
    
    for (ISKNoteView *v  in simpleNotepadStack.subviews) {
        
        CGRect newFrame = v.frame;
        newFrame.size.height -= TRANSFORM_WH;
        newFrame.size.width -= TRANSFORM_WH;
        newFrame.origin.x +=TRANSFORM_WH/2;
        newFrame.origin.y +=TRANSFORM_WH/2;
        v.frame = newFrame;
        if (![v.class isSubclassOfClass:[UITextView class]]) {
        [v.layer setMasksToBounds:NO ];
        [v.layer setShadowColor:[[UIColor blackColor ] CGColor ] ];
        [v.layer setShadowOpacity:0.65 ];
        [v.layer setShadowRadius:6.0 ];
        [v.layer setShadowOffset:CGSizeMake( 0 , 0 ) ];
        [v.layer setShouldRasterize:YES ];
        }
        
    }
    
}

-(void)expandStack {
    
    for (ISKNoteView *v  in simpleNotepadStack.subviews) {
        
        CGRect newFrame = v.frame;
        newFrame.size.height += TRANSFORM_WH;
        newFrame.size.width += TRANSFORM_WH;
        newFrame.origin.x -=TRANSFORM_WH/2;
        newFrame.origin.y -=TRANSFORM_WH/2;
        v.frame = newFrame;
        
        [v.layer setShadowOpacity:0];
        
    }
    
}

-(void)animateUp  {
    [UIView beginAnimations:nil context:NULL];
    CGPoint p = simpleNotepadStack.center;
    p.y -= TRANSITION_Y_AXIS;
    simpleNotepadStack.center = p;
    secondView.alpha = 1;
    thirdView.alpha = 1;
    [self squeezeStack];
    [self addShadow];
    [UIView commitAnimations];
    
    pagingScrollView.pagingEnabled = YES;
    pagingScrollView.scrollEnabled = YES;
    clearGR.enabled = NO;
    flipGR.enabled= NO;
    revealGR.enabled = NO;
    hideGR.enabled = YES;
    noteText.editable = NO;
    noteText.userInteractionEnabled = NO;
}


-(void)animateDown  {
    [UIView beginAnimations:nil context:NULL];
    CGPoint p = simpleNotepadStack.center;
    p.y += TRANSITION_Y_AXIS;
    simpleNotepadStack.center = p;
    secondView.alpha = 0;
    thirdView.alpha = 0;
    [self expandStack];
    [self hideShadow];
    [UIView commitAnimations];
    
    pagingScrollView.pagingEnabled = NO;
    pagingScrollView.scrollEnabled = NO;
    flipGR.enabled= YES;
    revealGR.enabled = YES;
    clearGR.enabled = YES;
    hideGR.enabled = NO;
    
    noteText.editable = YES;
    noteText.userInteractionEnabled = YES;
}

-(void)setupShadow {
    
    overlay = [[UIView alloc]initWithFrame:self.view.frame];
    overlay.alpha = 0;
    overlay.backgroundColor = [UIColor blackColor];
    [overlay setUserInteractionEnabled: NO];
    //overlay.backgroundColor = [UIColor blackColor];
    [self.view addSubview:overlay];
    
    
//        int radius = 200;
//        CAShapeLayer *circle = [CAShapeLayer layer];
//        circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*radius, 2.0*radius)
//                                                 cornerRadius:radius].CGPath;
//        // Center the shape in self.view
//        circle.position = CGPointMake(CGRectGetMidX(self.view.frame)-radius,
//                                      CGRectGetMidY(self.view.frame)-radius);
//        circle.fillColor = [UIColor clearColor].CGColor;
//        circle.strokeColor = [UIColor blackColor].CGColor;
//        circle.lineWidth = 5;
//            [circle setMasksToBounds:NO ];
//            [circle setShadowColor:[[UIColor blackColor ] CGColor ] ];
//            [circle setShadowOpacity:0.65 ];
//            [circle setShadowRadius:300.0 ];
//            [circle setShadowOffset:CGSizeMake(0 ,0 ) ];
//            [circle setShouldRasterize:YES ];
//            [circle setShadowPath:circle.path];
//    
//        [overlay.layer addSublayer:circle];
    
//        [overlay.layer setMasksToBounds:NO ];
//        [overlay.layer setShadowColor:[[UIColor blackColor ] CGColor ] ];
//        [overlay.layer setShadowOpacity:0.65 ];
//        [overlay.layer setShadowRadius:16.0 ];
//        [overlay.layer setShadowOffset:CGSizeMake( 0 , 0 ) ];
//        [overlay.layer setShouldRasterize:YES ];
//        [overlay.layer setShadowPath:[[UIBezierPath bezierPathWithRect:self.view.frame ] CGPath ] ];
    //

}

-(void)addShadow {
    
    overlay.alpha = 0.3;
}

-(void)hideShadow {
    
    overlay.alpha = 0;
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




#pragma mark - TextView

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
   
    [self toggleArrows:scrollView];
    
   


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
