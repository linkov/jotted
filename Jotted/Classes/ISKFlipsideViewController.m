//
//  ISKFlipsideViewController.m
//  IndexStack
//
//  Created by Alexey Linkov on 9/1/12.
//  Copyright (c) 2012 Alexey Linkov. All rights reserved.
//
#import "ISKDrawingView.h"
#import "ISKFlipsideViewController.h"

@interface ISKFlipsideViewController ()
@property (nonatomic, strong) ISKDrawingView *drawScreen;

@property (strong) UIColor *noteColor;
@property int noteTag;

@end

@implementation ISKFlipsideViewController

- (id)initWithColor:(UIColor *)color noteTag:(int)noteTag delegate:(id)delegate {

	if (self = [super init]) {

		self.delegate = delegate;
		self.noteColor = color;
		self.noteTag = noteTag;
	}

	return self;
}

- (void)viewDidLoad {

	[self.view.layer setCornerRadius:STACKCORNERRAD];
	self.view.backgroundColor = self.noteColor;

	ISKDrawingView *ds = [[ISKDrawingView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, [[UIScreen mainScreen] bounds].size.height - 20)];
	self.drawScreen = ds;

	self.drawScreen.brush = UIColorFromRGB(0x102855);


	NSString *docsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
	NSString *path = [docsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"textNoteDrawing_%i", self.noteTag]];

	NSData *bezierData = [NSData dataWithContentsOfFile:path];

	if (bezierData) {

		UIBezierPath *bezierPath = [NSKeyedUnarchiver unarchiveObjectWithData:bezierData];

		if (bezierPath) {

			self.drawScreen.mainPath = bezierPath;
		}
	}


	[self.view addSubview:self.drawScreen];

	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeSystem];
	doneButton.frame = CGRectMake(self.view.width-80, 10, 55, 44);
	// doneButton.layer.cornerRadius = STACKCORNERRAD;
	// doneButton.layer.borderWidth = 1;
	// doneButton.layer.borderColor = [UIColorFromRGB(0xF6F6F6) CGColor];
	[doneButton setTitle:@"Done" forState:UIControlStateNormal];
	//  [doneButton setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
	//  doneButton.backgroundColor = UIColorFromRGB(0xE8E8E8);
	[doneButton addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
	//  doneButton.alpha = 0.7;
	[self.view addSubview:doneButton];
}

- (BOOL)prefersStatusBarHidden {

	return YES;
}

- (void)done {

	NSString *docsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
	NSString *path = [docsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"textNoteDrawing_%i", self.noteTag]];

	NSData *bezierData = [NSKeyedArchiver archivedDataWithRootObject:self.drawScreen.mainPath];
	[bezierData writeToFile:path atomically:YES];


	[self.delegate flipsideViewControllerDidFinishWithView:self.noteTag];
}

- (void)dealloc {
	_delegate  = nil;
}

@end
