//
//  ISKMainViewController.m
//  IndexStack
//
//  Created by Alexey Linkov on 9/1/12.
//  Copyright (c) 2012 Alexey Linkov. All rights reserved.
//


#define TRANSITION_Y_AXIS 108
#define TRANSFORM_WH 25

#import "ISKNoteView.h"
#import "ISKSimpleStackViewController.h"

#import <Crashlytics/Crashlytics.h>
#import "ISKTiltRevealMotionEffect.h"
#import "ISKStacksViewController.h"
#import "ISKGravityCollisionBehavior.h"

@interface ISKSimpleStackViewController () {
    
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
    BOOL isFirstScreen;
    CGSize keyboardSize;
}
@property(retain)  UIDynamicAnimator *stackAnimator;
@property(retain)  NSArray *viewTags;
@property(assign)  ISKStacksViewController *delegate;
@property (retain) UIButton *shareButton;
@property (retain) UIImage *noteSnapShot;

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
@synthesize simpleNotepadStack;


- (id)initWithTags:(NSArray *)viewTags delegate:(ISKStacksViewController *)delegate
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _viewTags = [viewTags retain];
        _delegate = delegate;
    }
    return self;
}

-(void)loadView
{
    
    self.view = [[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height)]autorelease];
    
    ISKRootView *rv = [[ISKRootView alloc]initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    self.simpleNotepadStack = rv;
    [rv release];
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
    firstView.tag = [self.viewTags[0] intValue];
    
    secondView = [[ISKNoteView alloc]initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height)];
    secondView.backgroundColor = BLUECOLOR;
    secondView.alpha = 0;
    secondView.tag = [self.viewTags[1] intValue];
    
    thirdView = [[ISKNoteView alloc]initWithFrame:CGRectMake(0, 88, self.view.frame.size.width, self.view.frame.size.height)];
    thirdView.backgroundColor = REDCOLOR;
    thirdView.alpha = 0;
    thirdView.tag = [self.viewTags[2] intValue];
    
    [secondView addGestureRecognizer:switchViewGR];
    [thirdView addGestureRecognizer:switchViewGR2];
    [switchViewGR release];
    [switchViewGR2 release];
    
    

    
   // pagingScrollView = self.delegate.pagingScrollView;
    //pageControl = self.delegate.pageControl;
    
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
    
    [simpleNotepadStack addSubview:firstView];
    [simpleNotepadStack insertSubview:secondView belowSubview:firstView];
    [simpleNotepadStack insertSubview:thirdView belowSubview:secondView];
    
    //[pagingScrollView  addSubview:simpleNotepadStack];
   // [pagingScrollView addSubview:checklistNotepadStack];
    [self.view addSubview:simpleNotepadStack];
    
    
    
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
    
    doneButton = [UIButton buttonWithType:UIButtonTypeSystem];
    doneButton.frame = CGRectMake(255, 10, 55, 44);
    
   // doneButton.layer.cornerRadius = STACKCORNERRAD;
  //  doneButton.layer.borderWidth = 1;
   // doneButton.layer.borderColor = [UIColorFromRGB(0xF6F6F6) CGColor];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
   // [doneButton setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
  //  doneButton.backgroundColor = UIColorFromRGB(0xE8E8E8);
    [doneButton addTarget:self action:@selector(finishEdit) forControlEvents:UIControlEventTouchUpInside];
    doneButton.alpha = 0;
    [simpleNotepadStack addSubview:doneButton];
    
    activeView = firstView.tag;
    
    noteText.text =  [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"textNote_%i",activeView]];

    
    upArrow = [[UIImageView alloc]initWithFrame:CGRectMake(320/2-9/2, 40, 9, 6)];
    upArrow.image = [UIImage imageNamed:@"blackArrowUp"];
    upArrow.alpha = 0;
    
    [simpleNotepadStack addSubview:upArrow];
    [upArrow release];
    
    downArrow = [[UIImageView alloc]initWithFrame:CGRectMake(320/2-9/2, noteText.frame.size.height+65, 9, 6)];
    downArrow.image = [UIImage imageNamed:@"blackArrowDown"];
    downArrow.alpha = 0;
    
    [simpleNotepadStack addSubview:downArrow];
    [downArrow release];
    
    //[self toggleArrows:noteText];
    
    pencil = [[UIImageView alloc]initWithFrame:CGRectMake(320/2-7, 25, 15, 15)];
    pencil.image = [[UIImage imageNamed:@"blackPencil"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    pencil.alpha = 0;
    

    
    
    
    [simpleNotepadStack addSubview:pencil];
    [pencil release];
    
    [self manageFirstLaunch];
    
    [self updateAppSettings];
    
    [self checkDrawings];
    
    
    
    [self setupOverlay];


    CGSize paddedSize = CGSizeMake(noteText.contentSize.width, noteText.contentSize.height);
    noteText.contentSize = paddedSize;
    noteText.contentInset = UIEdgeInsetsMake(-16, 0, 0, 0);
    
    // TextKit stuff
    [noteText.layoutManager setUsesFontLeading:YES];
    NSLog(@"textContainer = %@",noteText.textContainer);
    NSLog(@"layoutManager = %@",noteText.layoutManager);
   // noteText.layoutManager
    // text tight trait
    NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
    [paragrahStyle setLineSpacing:2];
    
    [noteText.textStorage setAttributes:@{NSParagraphStyleAttributeName:paragrahStyle} range:NSMakeRange(0, [noteText.text length])];
    [paragrahStyle release];
    [self toggleArrows:noteText];
    
//    UIInterpolatingMotionEffect *mFV = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
//    UIInterpolatingMotionEffect *mFH = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
//    [mFV setMaximumRelativeValue:[NSValue valueWithCGPoint:CGPointMake(30.4, 11.2)]];
//    [mFV setMinimumRelativeValue:[NSValue valueWithCGPoint:CGPointMake(3.4, 1.2)]];
//    [mFH setMaximumRelativeValue:[NSValue valueWithCGPoint:CGPointMake(30.4, 11.2)]];
//    [mFH setMinimumRelativeValue:[NSValue valueWithCGPoint:CGPointMake(3.4, 1.2)]];
//    
//    [noteText addMotionEffect:mFV];
//    [noteText addMotionEffect:mFH];
//    [mFH release];
//    [mFV release];
    
    //pencil.alpha = 0;
        [pencil addMotionEffect:[[ISKTiltRevealMotionEffect new] autorelease]];
    
    
    
    
    self.shareButton = [UIButton buttonWithType:UIButtonTypeSystem];

    _shareButton.frame = CGRectMake(320/2-60/2, -34, 60, 34);
    [_shareButton setTitle:@"Share" forState:UIControlStateNormal];
    _shareButton.layer.cornerRadius = STACKCORNERRAD;
   // _shareButton.layer.borderColor = [UIColor blackColor].CGColor;
  //  _shareButton.layer.borderWidth = 1;
    _shareButton.backgroundColor = [UIColor whiteColor];
    _shareButton.alpha = 0.9;
    [_shareButton addTarget:self action:@selector(shareNote) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.shareButton];
    
    }


-(void)shareNote {
    


    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[self.noteSnapShot] applicationActivities:nil];
    activityController.excludedActivityTypes = @[UIActivityTypeAssignToContact,UIActivityTypeCopyToPasteboard];

    [self presentViewController:activityController animated:YES completion:nil];
    [activityController release];
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
        
        
        
        noteText.text = @"Swipe up to reveal all notes\nDoodle on the flip side of a note\nClean flip side with 2 finger tap\nSwipe left to flip this note\nSwipe right to delete this text\n";
        
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
        activeView = [self.viewTags[0] intValue];
        NSLog(@"First view YELLOW");
    }
    else if ([firstView.backgroundColor isEqual:BLUECOLOR ]) {
        
        activeView = [self.viewTags[1] intValue];
         NSLog(@"First view BLUE");
    }
    else if ([firstView.backgroundColor isEqual: REDCOLOR]) {
        activeView = [self.viewTags[2] intValue];
        NSLog(@"First view RED");
    }
    
    noteText.text =  [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"textNote_%i",activeView]];
    
   // CGSize paddedSize = CGSizeMake(noteText.contentSize.width, noteText.contentSize.height-10);
    CGSize paddedSize = CGSizeMake(noteText.contentSize.width, noteText.contentSize.height);
    noteText.contentSize = paddedSize;
    /// [noteText scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
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
                pencil.alpha = 1.0;
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
    
    for (ISKNoteView *v  in simpleNotepadStack.subviews) {
     
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
    
    if (self.delegate.activeStack ==self) {
     
        CGRect rect = [self.view bounds];
        UIGraphicsBeginImageContextWithOptions(rect.size,NO,0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [self.view.layer renderInContext:context];
        UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        self.noteSnapShot = capturedImage;
    }
    
    // TODO: check out animateWithDuration damping velocity when this is added to iOS7 API seed
    [UIView animateWithDuration:0.2 animations:^{
        
        CGPoint p = simpleNotepadStack.center;
        p.y -= TRANSITION_Y_AXIS;
        
        simpleNotepadStack.center = p;
        secondView.alpha = 1;
        thirdView.alpha = 1;
        self.shareButton.y += 30;
        [self squeezeStack];
       // [self addOverlay];
        
    } completion:^(BOOL finished) {
        
        clearGR.enabled = NO;
        flipGR.enabled= NO;
        revealGR.enabled = NO;
        hideGR.enabled = YES;
        noteText.editable = NO;
        noteText.userInteractionEnabled = NO;
        
        if (self.delegate.activeStack ==self) {
            
            self.delegate.pageControl.alpha =1;
            self.delegate.pagingScrollView.pagingEnabled = YES;
            self.delegate.pagingScrollView.scrollEnabled = YES;
        }

        
        [self applyDynamics];
        
    }];
    
    

}

-(NSString *)description {
    
    return [self.viewTags componentsJoinedByString:@", "];
}

-(void)applyDynamics  {
    
    
    ISKGravityCollisionBehavior *gravCol = [[ISKGravityCollisionBehavior alloc]initWithItems:@[secondView] collisionDelegate:self];
    
   // UIGravityBehavior *gravity = [[UIGravityBehavior alloc]initWithItems:@[secondView]];
   // gravity.yComponent = -0.1;
    
    //    UIAttachmentBehavior *at = [[UIAttachmentBehavior alloc]initWithItem:noteText attachedToAnchor:CGPointMake(30, 20)];
    //    [at setFrequency:4.0];
    //    [at setDamping:0.5];
    //
   // UICollisionBehavior *collision = [[UICollisionBehavior alloc]initWithItems:@[secondView]];
   // collision.collisionMode = UICollisionBehaviorModeBoundaries;
   // [collision setTranslatesReferenceBoundsIntoBoundary:YES];
   // collision.collisionDelegate = self;
    
    
//    UIDynamicItemBehavior *elast = [[UIDynamicItemBehavior alloc]initWithItems:@[secondView]];
//    elast.elasticity = 0.1;
//    elast.friction = 1.0;
//    [gravCol addChildBehavior:elast];
//    [elast release];
    
    _stackAnimator = [[UIDynamicAnimator alloc]initWithReferenceView:simpleNotepadStack];
    [_stackAnimator addBehavior:gravCol];
    [gravCol release];
//    [_stackAnimator addBehavior:gravity];
//    [_stackAnimator addBehavior:collision];
    // [_stackAnimator addBehavior:at];
//    [gravity release];
//    [collision release];
    // [at release];
}



-(void)collisionBehavior:(UICollisionBehavior *)behavior endedContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier {
    
    NSLog(@"item = %@",item);
    
    UIDynamicItemBehavior *itemB = [[[UIDynamicItemBehavior alloc]initWithItems:@[item]] autorelease];
    itemB.angularResistance = 0.2;
    
    UIPushBehavior *push = [[[UIPushBehavior alloc]initWithItems:@[item] mode:UIPushBehaviorModeContinuous
                             ] autorelease];
    //[push setTargetPoint:CGPointMake(10, 5) forItem:item];
    //[push setTargetOffsetFromCenter:UIOffsetMake(0, 0) forItem:item];
   // [push setXComponent:-0.9 yComponent:-0.5];
    [push setPushDirection:CGVectorMake(-0.9, -0.5)];
    
    
    
    UISnapBehavior *s = [[[UISnapBehavior alloc]initWithItem:item snapToPoint:CGPointMake(159.5, 330)] autorelease];
    [s setDamping:0.5];
   
    
    [self.stackAnimator removeAllBehaviors];
    [self.stackAnimator addBehavior:s];
  //  [self.stackAnimator addBehavior:itemB];
}


-(void)animateDown  {
    
    
    self.delegate.pageControl.alpha = 0;
    
    [UIView animateWithDuration:0.2 animations:^{
       
        CGPoint p = simpleNotepadStack.center;
        p.y += TRANSITION_Y_AXIS;
        simpleNotepadStack.center = p;
        secondView.alpha = 0;
        thirdView.alpha = 0;
        self.shareButton.y -= 30;
        [self expandStack];
       // [self hideOverlay];

        
    } completion:^(BOOL finished) {
        
        self.delegate.pagingScrollView.pagingEnabled = NO;
        self.delegate.pagingScrollView.scrollEnabled = NO;
        flipGR.enabled= YES;
        revealGR.enabled = YES;
        clearGR.enabled = YES;
        hideGR.enabled = NO;
        
        noteText.editable = YES;
        noteText.userInteractionEnabled = YES;
       
        

        
    }];
    
}

-(void)setupOverlay {
    
    overlay = [[UIView alloc]initWithFrame:self.view.frame];
    overlay.alpha = 0;
    overlay.backgroundColor = [UIColor blackColor];
    [overlay setUserInteractionEnabled: NO];
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
    
    UIFontDescriptor *helNeueFamily = [UIFontDescriptor fontDescriptorWithFontAttributes:@{UIFontDescriptorFamilyAttribute:@"Helvetica Neue"}];
    
    NSLog(@"%@",[helNeueFamily matchingFontDescriptorsWithMandatoryKeys:nil]);
    
    noteText.font = [UIFont fontWithName:@"Noteworthy-Light" size:20];
    
    
//    BOOL smallFont = [[NSUserDefaults standardUserDefaults] boolForKey:@"enableSmallerFont"];
//    
//    if (smallFont == YES) {
//        
//        noteText.font = [UIFont fontWithName:@"Noteworthy-Light" size:20];
//
//    }
//    else {
//        
//        noteText.font = [UIFont fontWithName:@"Noteworthy-Light" size:24];
//
//    }
    
    
   // CGSize paddedSize = CGSizeMake(noteText.contentSize.width, noteText.contentSize.height-10);
    CGSize paddedSize = CGSizeMake(noteText.contentSize.width, noteText.contentSize.height);
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
    
    
    // 18 for big text
    if (scroll.contentOffset.y >18) {
        
        upArrow.alpha = 1;
    }
    else {
        upArrow.alpha = 0;
    }
    //-24 for big text
    //if ( (scroll.contentSize.height-6 > scroll.frame.size.height+(scroll.contentOffset.y == 16 ? 0 : scroll.contentOffset.y ) )) {
    if ( (scroll.contentSize.height-8 > scroll.frame.size.height+scroll.contentOffset.y )) {
        
//        NSLog(@" scroll.contentOffset.y = %f",scroll.contentOffset.y);
//        NSLog(@" scroll.frame.size.height = %f",scroll.frame.size.height);
//        NSLog(@" scroll.contentSize.height = %f",scroll.contentSize.height);
        
         downArrow.alpha = 1;
        

    
    }
    else {
        
        downArrow.alpha = 0;
        

    }
//    if (downArrow.alpha == 0 && upArrow.alpha == 0) {
//        
//        scroll.scrollEnabled = NO;
//    }
//    else {
//        
//        scroll.scrollEnabled = YES;
//    }
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
    NSValue *aValue = info[UIKeyboardFrameBeginUserInfoKey];
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
    //CGSize paddedSize = CGSizeMake(noteText.contentSize.width, noteText.contentSize.height-10);
    CGSize paddedSize = CGSizeMake(noteText.contentSize.width, noteText.contentSize.height);
    noteText.contentSize = paddedSize;
    
    [self toggleArrows:noteText];
    
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
  //  if ([scrollView.superview isKindOfClass:[UITextView class]]) {
        
         [self toggleArrows:scrollView];

 //   }
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
    [self dismissViewControllerAnimated:YES completion:^{
        // [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    }];
   
    activeView = aView;
    
    [self checkDrawings];
}

- (void)showFlipside
{
  // [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    ISKFlipsideViewController *controller = [ISKFlipsideViewController new];
    controller.delegate = self;
    controller.activeNote = activeView;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:controller animated:YES completion:nil];
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
    [simpleNotepadStack release];
    [noteText release];
    [doneButton release];
    
    [super dealloc];
}

@end
