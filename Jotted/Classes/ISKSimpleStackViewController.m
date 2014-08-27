//
//  ISKMainViewController.m
//  IndexStack
//
//  Created by Alexey Linkov on 9/1/12.
//  Copyright (c) 2012 Alexey Linkov. All rights reserved.
//
#define APPSTORERATEURL @"itms-apps://itunes.apple.com/app/id560094563?at=10l6dK"
#define TRANSITION_Y_AXIS 108
#define TRANSFORM_WH 25

#import "ISKNoteView.h"
#import "ISKSimpleStackViewController.h"

#import "ISKTiltRevealMotionEffect.h"
#import "ISKStacksViewController.h"
#import "ISKGravityCollisionBehavior.h"
#import "PSPDFTextView.h"
#import "ISKDrawingView.h"
#import "Flurry.h"
#import "LMAlertView.h"
#import "EDStarRating.h"

static const NSUInteger ktextViewSideOffset = 10;
static const NSUInteger ktextViewTopOffset = 55;
static const NSUInteger ktextViewBottomOffset = 74;
static const NSUInteger kTextViewKeyboardOffset = 142;
static const NSUInteger kTextViewKeyboardOffsetActivateHeight = 250;

@interface ISKSimpleStackViewController () <EDStarRatingProtocol> {

	//UIScrollView *pagingScrollView;
	//StyledPageControl* pageControl;

	UISwipeGestureRecognizer *clearGR;
	UISwipeGestureRecognizer *flipGR;
	UISwipeGestureRecognizer *revealGR;
	UITapGestureRecognizer *hideGR;




	ISKNoteView *firstView;
	ISKNoteView *secondView;
	ISKNoteView *thirdView;


	UIView *overlay;
	int activeView;

	BOOL keyboardShown;
	BOOL isFirstScreen;
	CGSize keyboardSize;
	CGPoint centerBeforeAnimateUp;
	CGPoint secondViewCenterBeforeCollision;
}
@property (strong)  UIDynamicAnimator *stackAnimator;
@property (nonatomic, strong)  PSPDFTextView *noteText;

@property (weak)  ISKStacksViewController *delegate;
@property (nonatomic, strong) UIButton *shareButton;
@property (strong) UIImage *noteSnapShot;
@property (strong) UIImage *noteDrawingSnapShot;
@property (nonatomic, strong) UIButton *doneButton;

@property (nonatomic, strong) UIImageView *pencil;
@property (nonatomic, strong) UIImageView *upArrow;
@property (nonatomic, strong) UIImageView *downArrow;

@property (nonatomic, strong) NSString *storedTextString;

@property (strong) UITapGestureRecognizer *switchViewGR;
@property (strong) UITapGestureRecognizer *switchViewGR2;

@property (strong) LMAlertView *ratingAlertView;
@property (strong) EDStarRating *starRating;

- (void)toggleArrows:(UIScrollView *)scroll;
- (void)finishEdit;
- (void)manageFirstLaunch;
- (void)clearNote;
- (void)switchToView:(UIGestureRecognizer *)gr;
- (void)checkDrawings;
- (void)animateUp;
- (void)animateDown;
- (void)showFlipside;

//-(void)keyboardWasHidden:(NSNotification*)aNotification;
- (void)keyboardWasShown:(NSNotification *)aNotification;

@end

@implementation ISKSimpleStackViewController


- (id)initWithTags:(NSArray *)viewTags delegate:(ISKStacksViewController *)delegate {
	self = [super initWithNibName:nil bundle:nil];
	if (self) {
		_viewTags = viewTags;
		_delegate = delegate;
	}
	return self;
}

- (NSString *)storedTextString  {

   [self manageFirstLaunch];

    _storedTextString = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"textNote_%i", activeView]] ? :@"";

    return _storedTextString;
}

- (PSPDFTextView *)noteText {

    if (!_noteText) {

        _noteText = [[PSPDFTextView alloc]initWithFrame:CGRectMake(ktextViewSideOffset, ktextViewTopOffset, [[UIScreen mainScreen] bounds].size.width - ktextViewSideOffset * 2, [[UIScreen mainScreen] bounds].size.height - ktextViewBottomOffset - ktextViewTopOffset)];
        self.noteText.autocorrectionType  = UITextAutocorrectionTypeNo;
        self.noteText.backgroundColor = [UIColor clearColor];
        self.noteText.font = [UIFont fontWithName:@"Noteworthy-Light" size:20];
        self.noteText.textColor = UIColorFromRGB(0x102855);
        self.noteText.delegate = self;
        self.noteText.editable = NO;
        self.noteText.userInteractionEnabled = NO;
        [self.simpleNotepadStack addSubview:self.noteText];

        CGRect newFrame = self.noteText.frame;
        newFrame.size.height -= TRANSFORM_WH;
        newFrame.size.width -= TRANSFORM_WH;
        newFrame.origin.x += TRANSFORM_WH / 2;
        newFrame.origin.y += TRANSFORM_WH / 2;
        self.noteText.frame = newFrame;

    }
    return _noteText;
}

- (UIButton *)doneButton {

    if (!_doneButton) {

        _doneButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _doneButton.frame = CGRectMake(self.view.width - 80, 10, 55, 44);

        // doneButton.layer.cornerRadius = STACKCORNERRAD;
        //  doneButton.layer.borderWidth = 1;
        // doneButton.layer.borderColor = [UIColorFromRGB(0xF6F6F6) CGColor];
        [_doneButton setTitle:@"Done" forState:UIControlStateNormal];
        // [doneButton setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
        //  doneButton.backgroundColor = UIColorFromRGB(0xE8E8E8);
        [_doneButton addTarget:self action:@selector(finishEdit) forControlEvents:UIControlEventTouchUpInside];
        _doneButton.alpha = 0;
        [self.simpleNotepadStack addSubview:self.doneButton];
    }
    return _doneButton;
}

- (UIImageView *)upArrow {

    if (!_upArrow) {

        _upArrow = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.width / 2 - 9 / 2, 40, 9, 6)];
        _upArrow.image = [UIImage imageNamed:@"blackArrowUp"];
        _upArrow.alpha = 0;

        [self.simpleNotepadStack addSubview:self.upArrow];
    }

    return _upArrow;
}

- (UIImageView *)downArrow {

    if (!_downArrow) {


        _downArrow = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.width / 2 - 9 / 2, self.noteText.frame.size.height + 65, 9, 6)];
        _downArrow.image = [UIImage imageNamed:@"blackArrowDown"];
        _downArrow.alpha = 0;

        [self.simpleNotepadStack addSubview:self.downArrow];
    }

    return _downArrow;

}

- (UIImageView *)pencil {


    if (!_pencil) {

        _pencil = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.width / 2 - 7, 25, 15, 15)];
        _pencil.image = [[UIImage imageNamed:@"blackPencil"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _pencil.alpha = 0;

        [self.simpleNotepadStack addSubview:self.pencil];
    }

    return _pencil;

}

- (void)loadActiveView {

    NSString *textString = [self storedTextString];


    if (textString.length > 0) {


        [self updateTextViewText:self.storedTextString];


        self.noteText.textColor = UIColorFromRGB(0x102855);
        self.noteText.font = [UIFont fontWithName:@"Noteworthy-Light" size:20];
        [self.noteText setScrollEnabled:YES];
        [self checkDrawings];
        [self setupOverlay];

        self.noteText.contentInset = UIEdgeInsetsMake(-16, 0, 0, 0);

        // TextKit stuff
        [self.noteText.layoutManager setUsesFontLeading:YES];

        [self toggleArrows:self.noteText];


    }


    if (!self.shareButton) {


        _shareButton = [UIButton buttonWithType:UIButtonTypeSystem];

        _shareButton.frame = CGRectMake(self.view.width / 2 - 60 / 2, -34, 60, 34);
        [_shareButton setTitle:@"Share" forState:UIControlStateNormal];
        _shareButton.layer.cornerRadius = STACKCORNERRAD;
        _shareButton.backgroundColor = [UIColor whiteColor];
        _shareButton.alpha = 0.9;
        [_shareButton addTarget:self action:@selector(shareNote) forControlEvents:UIControlEventTouchUpInside];

        [self.view addSubview:self.shareButton];
    }


    


}

- (void)viewDidLoad {

	[super viewDidLoad];

    _simpleNotepadStack = [[ISKRootView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];


	flipGR = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(showFlipside)];
	flipGR.direction = UISwipeGestureRecognizerDirectionLeft;

	clearGR = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(clearNote)];
	clearGR.direction = UISwipeGestureRecognizerDirectionRight;

	revealGR = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(animateUp)];
	revealGR.direction = UISwipeGestureRecognizerDirectionUp;

	hideGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(animateDown)];
	//    hideGR.direction = UISwipeGestureRecognizerDirectionDown;
	hideGR.enabled = NO;

	_switchViewGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(switchToView:)];
	self.switchViewGR.numberOfTapsRequired = 1;

	_switchViewGR2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(switchToView:)];
	self.switchViewGR2.numberOfTapsRequired = 1;

	[self.simpleNotepadStack addGestureRecognizer:clearGR];
	[self.simpleNotepadStack addGestureRecognizer:flipGR];
	[self.simpleNotepadStack addGestureRecognizer:revealGR];
	[self.view addGestureRecognizer:hideGR];


	firstView = [[ISKNoteView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	firstView.backgroundColor = YELLOWCOLOR;
	firstView.tag = [self.viewTags[0] intValue];

	secondView = [[ISKNoteView alloc]initWithFrame:CGRectMake(0, self.view.height * 0.08, self.view.frame.size.width, self.view.frame.size.height)];
	secondView.backgroundColor = BLUECOLOR;
	secondView.alpha = 0;
	secondView.tag = [self.viewTags[1] intValue];

	thirdView = [[ISKNoteView alloc]initWithFrame:CGRectMake(0, self.view.height * 0.155, self.view.frame.size.width, self.view.frame.size.height)];
	thirdView.backgroundColor = REDCOLOR;
	thirdView.alpha = 0;
	thirdView.tag = [self.viewTags[2] intValue];

	[secondView addGestureRecognizer:self.switchViewGR];
	[thirdView addGestureRecognizer:self.switchViewGR2];

	[self.simpleNotepadStack addSubview:firstView];
	[self.simpleNotepadStack insertSubview:secondView belowSubview:firstView];
	[self.simpleNotepadStack insertSubview:thirdView belowSubview:secondView];

	[self.view addSubview:self.simpleNotepadStack];

    activeView = firstView.tag;

}

- (void)shareNote {


	if (self.pencil.alpha == 1 && self.noteText.attributedText.length > 0) {

		UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Share"
		                                                   delegate:self
		                                          cancelButtonTitle:@"Cancel"
		                                     destructiveButtonTitle:nil
		                                          otherButtonTitles:@"Note image", @"Note text", nil];

		// Show the sheet
		[sheet showInView:self.simpleNotepadStack];
	} else if (self.pencil.alpha != 1 && self.noteText.attributedText.length > 0) {

		[self shareNoteText];
	} else if (self.pencil.alpha == 1 && self.noteText.attributedText.length == 0) {

		[self shareNoteDrawing];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) [self shareNoteDrawing];
	if (buttonIndex == 1) [self shareNoteText];
}


- (void)shareNoteText {

	UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[[self storedTextString]]
                                                                                     applicationActivities:nil];
	activityController.excludedActivityTypes = @[UIActivityTypeAssignToContact];
    [activityController setCompletionHandler:^(NSString *activityType, BOOL completed) {

        if (completed) {
            [Flurry logEvent:@"Note_Share" withParameters:@{ @"shareMode" : @"text" }];
            [self showRateAlertIfNeeded];
        }

    }];


	[self presentViewController:activityController animated:YES completion:nil];
}

- (void)shareNoteDrawing {


	UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[self.noteDrawingSnapShot] applicationActivities:nil];
	activityController.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard];

    [activityController setCompletionHandler:^(NSString *activityType, BOOL completed) {

        if (completed) {

            [Flurry logEvent:@"Note_Share" withParameters:@{ @"shareMode":@"drawing" }];
            [self showRateAlertIfNeeded];
        }

    }];

	[self presentViewController:activityController animated:YES completion:nil];
}

- (void)finishEdit {

	[self.noteText resignFirstResponder];
	self.noteText.height = [[UIScreen mainScreen] bounds].size.height - ktextViewBottomOffset - ktextViewTopOffset;
}

- (void)manageFirstLaunch {

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]) {
	} else {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
		[[NSUserDefaults standardUserDefaults] synchronize];

		NSString *welcomeText = @"Swipe up to reveal all notes, doodle on the flip side of a note, clean flip side with 2 finger tap, swipe left to flip this note, swipe right to delete this text";

		[[NSUserDefaults standardUserDefaults] setValue:welcomeText forKey:[NSString stringWithFormat:@"textNote_%i", activeView]];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

- (void)clearNote {

	if (self.noteText.attributedText.length > 0) {

		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Clear all text?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Clear", nil];
		alert.tag = 11;
		[alert show];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

	if (alertView.tag == 11) {

		if (buttonIndex != 0) {
			[self updateTextViewText:@""];
			[[NSUserDefaults standardUserDefaults] setValue:[self.noteText.attributedText string] forKey:[NSString stringWithFormat:@"textNote_%i", activeView]];
			[[NSUserDefaults standardUserDefaults] synchronize];

			[self toggleArrows:self.noteText];
		}
	} else {


		if (buttonIndex == 1) {

			[Flurry logEvent:@"a2_rate_alert_submit"];

			if (self.starRating.rating > 3) {
				[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"DidPushRateLaterKey"];
				[self openRating];
			} else {
				[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"DidPushRateLaterKey"];
				[self openEmail];
			}
		} else {
			[Flurry logEvent:@"a2_rate_alert_notnow"];
			[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"DidPushRateLaterKey"];
			[[NSUserDefaults standardUserDefaults] setObject:[NSDate date]  forKey:@"WSCRidersTimeOfLastRateAlertKey"];
		}
	}
}

- (void)switchToView:(UITapGestureRecognizer *)gr {

	gr.enabled = NO;
	self.switchViewGR.enabled = NO;
	self.switchViewGR2.enabled = NO;

	self.downArrow.alpha = 0;
	self.upArrow.alpha = 0;

	[self animateDown];

	UIColor *toColor = gr.view.backgroundColor;
	UIColor *fromColor = firstView.backgroundColor;


	firstView.backgroundColor = toColor;
	gr.view.backgroundColor = fromColor;

	if ([firstView.backgroundColor isEqual:YELLOWCOLOR]) {
		activeView = [self.viewTags[0] intValue];
		NSLog(@"First view YELLOW");
	} else if ([firstView.backgroundColor isEqual:BLUECOLOR]) {

		activeView = [self.viewTags[1] intValue];
		NSLog(@"First view BLUE");
	} else if ([firstView.backgroundColor isEqual:REDCOLOR]) {
		activeView = [self.viewTags[2] intValue];
		NSLog(@"First view RED");
	}

	[self updateTextViewText:[[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"textNote_%i", activeView]]];


	[self toggleArrows:self.noteText];

	[self checkDrawings];
}

- (void)checkDrawings {

	NSString *docsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
	NSString *path = [docsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"textNoteDrawing_%i", activeView]];


	NSData *bezierData = [NSData dataWithContentsOfFile:path];

	if (bezierData) {

		UIBezierPath *bezierPath = [NSKeyedUnarchiver unarchiveObjectWithData:bezierData];
		if (bezierPath) {

			if ((bezierPath.bounds.size.width == 0 && bezierPath.bounds.size.height == 0) || bezierPath.isEmpty) {

				self.pencil.alpha = 0;
			} else {
				self.pencil.alpha = 1.0;
			}
		} else {
			self.pencil.alpha = 0;
		}
	} else {
		self.pencil.alpha = 0;
	}
}

- (void)squeezeStack {


	for (ISKNoteView *v in self.simpleNotepadStack.subviews) {

		if (![v.class isSubclassOfClass:[UIImageView class]] && ![v.class isSubclassOfClass:[UIControl class]]) {

			CGRect newFrame = v.frame;
			newFrame.size.height -= TRANSFORM_WH;
			newFrame.size.width -= TRANSFORM_WH;
			newFrame.origin.x += TRANSFORM_WH / 2;
			newFrame.origin.y += TRANSFORM_WH / 2;
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

- (void)expandStack {

	for (ISKNoteView *v in self.simpleNotepadStack.subviews) {

		if (![v.class isSubclassOfClass:[UIImageView class]] && ![v.class isSubclassOfClass:[UIControl class]]) {

            if ([v.class isSubclassOfClass:[UITextView class]] && v.frame.size.width == [[UIScreen mainScreen] bounds].size.width - ktextViewSideOffset * 2 ) {


            }
            else {


                CGRect newFrame = v.frame;
                newFrame.size.height += TRANSFORM_WH;
                newFrame.size.width += TRANSFORM_WH;
                newFrame.origin.x -= TRANSFORM_WH / 2;
                newFrame.origin.y -= TRANSFORM_WH / 2;
                v.frame = newFrame;
            }


			//[v.layer setShadowOpacity:0];
		}
	}
}

- (void)moveUp {

    CGPoint p = self.simpleNotepadStack.center;
    centerBeforeAnimateUp = p;
    p.y = centerBeforeAnimateUp.y * 0.62;

    self.simpleNotepadStack.center = p;
    secondView.alpha = 1;
    thirdView.alpha = 1;
    //if ([self storedTextString].length > 0 ||  self.pencil.alpha == 1.0) self.shareButton.y += 30;
    [self squeezeStack];

    clearGR.enabled = NO;
    flipGR.enabled = NO;
    revealGR.enabled = NO;
    hideGR.enabled = YES;

    if (self.delegate.activeStack == self) {

        self.delegate.pageControl.alpha = 1;
        self.delegate.pagingScrollView.pagingEnabled = YES;
        self.delegate.pagingScrollView.scrollEnabled = YES;
    }

}

- (void)animateUp  {

	if ([self storedTextString].length > 0) {

		UIView *snapShotView = [[UIView alloc]initWithFrame:self.view.frame];

		UIView *snapFirst = [[UIView alloc]initWithFrame:firstView.frame];
		snapFirst.backgroundColor = firstView.backgroundColor;
		snapFirst.layer.cornerRadius = firstView.layer.cornerRadius;
		[snapShotView addSubview:snapFirst];

		UILabel *snapText = [[UILabel alloc]initWithFrame:self.noteText.frame];
		snapText.font = self.noteText.font;
		snapText.attributedText = self.noteText.attributedText;
		snapText.lineBreakMode = NSLineBreakByWordWrapping;
		snapText.numberOfLines = 0;


		snapText.backgroundColor = self.noteText.backgroundColor;

		snapText.textColor = UIColorFromRGB(0x102855);

		[snapFirst addSubview:snapText];


		// if(noteText.contentSize.height > noteText.height)  {

		NSDictionary *fontdict = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Noteworthy-Light" size:20], NSFontAttributeName, nil];
		CGRect textFrame = [snapText.text boundingRectWithSize:CGSizeMake(self.noteText.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:fontdict context:nil];
		snapText.height = textFrame.size.height;
		snapShotView.height =  snapText.height + 100;
		snapFirst.height = snapText.height + 100;
		// [downArrow setHidden:YES];
		// }

		CGRect rect = [snapShotView bounds];
		UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
		CGContextRef context = UIGraphicsGetCurrentContext();
		[snapShotView.layer renderInContext:context];
		UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();


		self.noteSnapShot = capturedImage;
	}

	if (self.pencil.alpha == 1) {



		UIView *snapShotView = [[UIView alloc]initWithFrame:self.view.frame];
		snapShotView.backgroundColor = firstView.backgroundColor;
		snapShotView.layer.cornerRadius = firstView.layer.cornerRadius;

		ISKDrawingView *snapFirst = [[ISKDrawingView alloc]initWithFrame:firstView.frame];
		snapFirst.brush =  UIColorFromRGB(0x102855);


		NSString *docsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
		NSString *path = [docsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"textNoteDrawing_%i", activeView]];

		NSData *bezierData = [NSData dataWithContentsOfFile:path];

		if (bezierData) {

			UIBezierPath *bezierPath = [NSKeyedUnarchiver unarchiveObjectWithData:bezierData];

			if (bezierPath) {

				snapFirst.mainPath = bezierPath;
			}
		}


		[snapShotView addSubview:snapFirst];

		CGRect rect = [snapShotView bounds];
		UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
		CGContextRef context = UIGraphicsGetCurrentContext();
		[snapShotView.layer renderInContext:context];
		UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();


		self.noteDrawingSnapShot = capturedImage;
	}


	[UIView animateWithDuration:0.2 animations:^{

	    CGPoint p = self.simpleNotepadStack.center;
	    centerBeforeAnimateUp = p;
	    p.y = centerBeforeAnimateUp.y * 0.62;

	    self.simpleNotepadStack.center = p;
	    secondView.alpha = 1;
	    thirdView.alpha = 1;
	    if (self.noteText.attributedText.length > 0 ||  self.pencil.alpha == 1.0) self.shareButton.y += 30;
	    [self squeezeStack];
	    // [self addOverlay];
	} completion:^(BOOL finished) {

	    clearGR.enabled = NO;
	    flipGR.enabled = NO;
	    revealGR.enabled = NO;
	    hideGR.enabled = YES;
	    self.noteText.editable = NO;
	    self.noteText.userInteractionEnabled = NO;

	    if (self.delegate.activeStack == self) {

	        self.delegate.pageControl.alpha = 1;
	        self.delegate.pagingScrollView.pagingEnabled = YES;
	        self.delegate.pagingScrollView.scrollEnabled = YES;
		}


	    [self applyDynamics];
	}];
}

- (NSString *)description {

	return [self.viewTags componentsJoinedByString:@", "];
}

- (void)applyDynamics  {

    if (CGPointEqualToPoint(secondViewCenterBeforeCollision, CGPointZero)) {
        secondViewCenterBeforeCollision = secondView.center;
    }

	ISKGravityCollisionBehavior *gravCol = [[ISKGravityCollisionBehavior alloc]initWithItems:@[secondView] collisionDelegate:self];

	_stackAnimator = [[UIDynamicAnimator alloc]initWithReferenceView:self.simpleNotepadStack];
	[_stackAnimator addBehavior:gravCol];
}

- (void)collisionBehavior:(UICollisionBehavior *)behavior endedContactForItem:(id <UIDynamicItem> )item withBoundaryIdentifier:(id <NSCopying> )identifier {

	NSLog(@"item = %@", item);

	UIDynamicItemBehavior *itemB = [[UIDynamicItemBehavior alloc]initWithItems:@[item]];
	itemB.angularResistance = 0.2;

	UIPushBehavior *push = [[UIPushBehavior alloc]initWithItems:@[item] mode:UIPushBehaviorModeContinuous
	    ];
	//[push setTargetPoint:CGPointMake(10, 5) forItem:item];
	//[push setTargetOffsetFromCenter:UIOffsetMake(0, 0) forItem:item];
	// [push setXComponent:-0.9 yComponent:-0.5];
	[push setPushDirection:CGVectorMake(-0.9, -0.5)];



//    UISnapBehavior *s = [[[UISnapBehavior alloc]initWithItem:item snapToPoint:CGPointMake(159.5, [[ UIScreen mainScreen ] bounds ].size.height-200)] autorelease];
//    [s setDamping:0.5];
//

	UISnapBehavior *s = [[UISnapBehavior alloc]initWithItem:item snapToPoint:secondViewCenterBeforeCollision];
	[s setDamping:0.5];


	[self.stackAnimator removeAllBehaviors];
	[self.stackAnimator addBehavior:s];
	//  [self.stackAnimator addBehavior:itemB];
}

- (void)updateTextViewText:(NSString *)textString {

	self.noteText.text = textString;
}

- (void)animateDown  {

	if (roundf(self.simpleNotepadStack.center.y) <= roundf(centerBeforeAnimateUp.y * 0.62)) {

		self.delegate.pageControl.alpha = 0;

		[UIView animateWithDuration:0.2 animations:^{


		    self.simpleNotepadStack.center = centerBeforeAnimateUp;
		    secondView.alpha = 0;
		    thirdView.alpha = 0;
		    if (self.noteText.attributedText.length > 0 ||  self.pencil.alpha == 1.0) self.shareButton.y -= 30;
		    [self expandStack];
		    // [self hideOverlay];
		} completion:^(BOOL finished) {

		    self.delegate.pagingScrollView.pagingEnabled = NO;
		    self.delegate.pagingScrollView.scrollEnabled = NO;
		    flipGR.enabled = YES;
		    revealGR.enabled = YES;
		    clearGR.enabled = YES;
		    hideGR.enabled = NO;
		    self.switchViewGR.enabled = YES;
		    self.switchViewGR2.enabled = YES;

		    self.noteText.editable = YES;
		    self.noteText.userInteractionEnabled = YES;
		    //  [self.noteText setContentOffset:CGPointMake(0, 0)];
		    [self toggleArrows:self.noteText];
		}];
	}
}

- (void)setupOverlay {

	overlay = [[UIView alloc]initWithFrame:self.view.frame];
	overlay.alpha = 0;
	overlay.backgroundColor = [UIColor blackColor];
	[overlay setUserInteractionEnabled:NO];
	[self.view addSubview:overlay];
}

- (void)addOverlay {

	overlay.alpha = 0.3;
}

- (void)hideOverlay {

	overlay.alpha = 0;
}

- (void)viewWillAppear:(BOOL)animated {

	keyboardShown = NO;

	[[NSNotificationCenter defaultCenter] addObserver:self
	                                         selector:@selector(keyboardWasShown:)
	                                             name:UIKeyboardDidShowNotification object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
	                                         selector:@selector(keyboardWillHide:)
	                                             name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {

	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

//-(void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
//
//    CGSize paddedSize = CGSizeMake(scrollView.contentSize.width, scrollView.contentSize.height-18);
//    scrollView.contentSize = paddedSize;
//}

- (CGSize)text:(NSString *)text sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size {
	CGRect frame = [text boundingRectWithSize:size
	                                  options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
	                               attributes:@{ NSFontAttributeName:font }
	                                  context:nil];
	return frame.size;
}

- (void)toggleArrows:(UIScrollView *)scroll {


	// 18 for big text
	if (scroll.contentOffset.y > 18) {

		self.upArrow.alpha = 1;
	} else {
		self.upArrow.alpha = 0;
	}

	CGFloat contentHeight = [self text:[self.noteText.attributedText string] sizeWithFont:self.noteText.font constrainedToSize:CGSizeMake(self.noteText.frame.size.width, MAXFLOAT)].height;

	//-24 for big text
	//if ( (scroll.contentSize.height-6 > scroll.frame.size.height+(scroll.contentOffset.y == 16 ? 0 : scroll.contentOffset.y ) )) {
	if ((contentHeight - 8 > scroll.frame.size.height + scroll.contentOffset.y)) {

		self.downArrow.alpha = 1;
	} else {

		self.downArrow.alpha = 0;
	}

	NSLog(@" scroll.contentOffset.y = %f", scroll.contentOffset.y);
	NSLog(@" scroll.frame.size.height = %f", scroll.frame.size.height);
	NSLog(@" scroll.contentSize.height = %f", contentHeight);

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

	flipGR.enabled = NO;
	revealGR.enabled = NO;
	clearGR.enabled = NO;
	self.doneButton.alpha = 0.7;
	self.downArrow.alpha = 0;
	return YES;
}

- (void)textViewDidEndEditing:(UITextView *)tView {

	flipGR.enabled = YES;
	revealGR.enabled = YES;
	clearGR.enabled = YES;
	self.doneButton.alpha = 0;

	self.downArrow.alpha = 0;
	self.upArrow.alpha = 0;

	[[NSUserDefaults standardUserDefaults] setValue:tView.text forKey:[NSString stringWithFormat:@"textNote_%i", activeView]];
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


- (void)keyboardWasShown:(NSNotification *)aNotification {
	if (keyboardShown) {
		return;
	}

	CGRect viewFrame = [self.noteText frame];

	viewFrame.size.height -= self.noteText.contentSize.height > kTextViewKeyboardOffsetActivateHeight ? kTextViewKeyboardOffset : 0;

	self.noteText.frame = viewFrame;


	// Scroll the active text field into view.
	//CGRect textFieldRect = [activeField frame];
	[self.noteText scrollRectToVisible:viewFrame animated:YES];

	keyboardShown = YES;
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
	if (!keyboardShown) {
		return;
	}

	// Reset the height of the scroll view to its original value
	CGRect viewFrame = [self.noteText frame];

	viewFrame.size.height += self.noteText.contentSize.height > kTextViewKeyboardOffsetActivateHeight ? kTextViewKeyboardOffset : 0;

	self.noteText.frame = viewFrame;

	keyboardShown = NO;


	[self toggleArrows:self.noteText];
}

//-(void)keyboardWasHidden:(NSNotification*)aNotification {
//    if(!keyboardShown) {
//        return;
//    }
//
//    // Reset the height of the scroll view to its original value
//    CGRect viewFrame = [self.noteText frame];
//
//    viewFrame.size.height += keyboardSize.height-42+2-34;
//
//    self.noteText.frame = viewFrame;
//
//    keyboardShown = NO;
//
//
//    [self toggleArrows:self.noteText];
//
//}

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

- (void)flipsideViewControllerDidFinishWithView:(int)aView {

	[self dismissViewControllerAnimated:YES completion:^{
	    [self showRateAlertIfNeeded];
	}];

	activeView = aView;

	[self checkDrawings];
}

- (void)showFlipside {
	// [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
	ISKFlipsideViewController *controller = [[ISKFlipsideViewController alloc]initWithColor:firstView.backgroundColor noteTag:activeView delegate:self];
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Rate Alert

- (BOOL)isFirstRateDialog {

	if (![[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"didShowRate_v%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]]]) {
		[[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:[NSString stringWithFormat:@"didShowRate_v%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]]];
		return YES;
	}

	return NO;
}

- (NSInteger)daysBetweenDate:(NSDate *)fromDateTime andDate:(NSDate *)toDateTime {
	NSDate *fromDate;
	NSDate *toDate;

	NSCalendar *calendar = [NSCalendar currentCalendar];

	[calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
	             interval:NULL forDate:fromDateTime];
	[calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
	             interval:NULL forDate:toDateTime];

	NSDateComponents *difference = [calendar components:NSDayCalendarUnit
	                                           fromDate:fromDate toDate:toDate options:0];

	return [difference day];
}

- (void)showRateAlertIfNeeded {

    NSDate *lastRateAlertShowDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"WSCRidersTimeOfLastRateAlertKey"] ? : [NSDate date];

	NSUInteger daysInstalled = [self daysBetweenDate:[NSDate date] andDate:lastRateAlertShowDate];

	if ([self isFirstRateDialog] == YES || ([[NSUserDefaults standardUserDefaults] boolForKey:@"DidPushRateLaterKey"] == YES && daysInstalled >= 2)) { // prod
		[Flurry logEvent:@"a2_rate_alert_shown"];
		[self showRateAlert];
	}

}

- (void)showRateAlert {

	if (self.ratingAlertView != nil) {
		[self.ratingAlertView show];
		return;
	}

	self.ratingAlertView = [[LMAlertView alloc] initWithTitle:@"Tell us what you think"
	                                                  message:@"How would you rate your\nJotted experience?"
	                                                 delegate:self
	                                        cancelButtonTitle:@"Not Now"
	                                        otherButtonTitles:@"Submit", nil];

    self.ratingAlertView.tintColor = UIColorFromRGB(0x26ADE4);
	CGSize size = self.ratingAlertView.size;

	LMModalItemTableViewCell *cell = [self.ratingAlertView buttonCellForIndex:self.ratingAlertView.firstOtherButtonIndex];
	cell.isEnabled = NO;

	[self.ratingAlertView setSize:CGSizeMake(size.width, 190.0)];

	UIView *contentView = self.ratingAlertView.contentView;

	_starRating = [[EDStarRating alloc] initWithFrame:CGRectMake((size.width / 2.0 - 225.0 / 2.0), 95.0, 225.0, 50.0)];
	self.starRating.starImage            = [UIImage imageNamed:@"StarEmpty"];
	self.starRating.starHighlightedImage = [UIImage imageNamed:@"StarFull"];
	self.starRating.maxRating            = 5.0;
	self.starRating.delegate             = self;
	self.starRating.editable             = YES;
	self.starRating.displayMode          = EDStarRatingDisplayFull;
	self.starRating.rating               = 0;
	self.starRating.backgroundColor      = [UIColor clearColor];

	[contentView addSubview:self.starRating];

	[self.ratingAlertView show];
}

#pragma mark EDStarRatingProtocol delegate methods

- (void)starsSelectionChanged:(EDStarRating *)control rating:(float)rating {
	LMModalItemTableViewCell *submitCell = [self.ratingAlertView buttonCellForIndex:self.ratingAlertView.firstOtherButtonIndex];
	submitCell.isEnabled = (rating > 0);
}

- (void)openEmail {
	NSString *mailtoPrefix = [@"mailto:a.linkov@me.com?subject=Jotted - Feedback" stringByAddingPercentEscapesUsingEncoding : NSUTF8StringEncoding];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailtoPrefix]];
}

- (void)openRating  {

	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:APPSTORERATEURL]];
}

@end
