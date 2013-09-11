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
@property (nonatomic, retain) ISKDrawingView *drawScreen;
@end

@implementation ISKFlipsideViewController
@synthesize activeNote;


-(void)loadView
{
    
    
    self.view = [[UIView new] autorelease];
    [self.view.layer setCornerRadius:STACKCORNERRAD];
    
    if (self.activeNote == 64) {
        self.view.backgroundColor =YELLOWCOLOR;
    }
    else if (self.activeNote == 65) {
        
        self.view.backgroundColor =BLUECOLOR;
    }
    else if (self.activeNote == 66) {
        self.view.backgroundColor = REDCOLOR;
    }
    
    else if (self.activeNote == 67) {
        
        self.view.backgroundColor =YELLOWCOLOR;
    }
    else if (self.activeNote == 68) {
        self.view.backgroundColor = BLUECOLOR;
    }
    else if (self.activeNote == 69) {
        self.view.backgroundColor = REDCOLOR;
    }
    
    else if (self.activeNote == 70) {
        
        self.view.backgroundColor =YELLOWCOLOR;
    }
    else if (self.activeNote == 71) {
        self.view.backgroundColor = BLUECOLOR;
    }
    else if (self.activeNote == 72) {
        self.view.backgroundColor = REDCOLOR;
    }


    
    
    ISKDrawingView *ds = [[ISKDrawingView alloc]initWithFrame:CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height-20)];
    self.drawScreen = ds;
    [ds release];
    
    BOOL blackInk = [[NSUserDefaults standardUserDefaults] boolForKey:@"enableBlueInk"];
    
    if (blackInk == YES) {
        
        self.drawScreen.brush = UIColorFromRGB(0x102855);
    }
    else {
        
        self.drawScreen.brush = [UIColor blackColor];
    }
    
    
    NSString * docsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString * path = [docsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"textNoteDrawing_%i",activeNote]];
    
    NSData *bezierData = [NSData dataWithContentsOfFile:path];
    
    if (bezierData) {
        
        UIBezierPath *bezierPath = [NSKeyedUnarchiver unarchiveObjectWithData:bezierData];
        
        if (bezierPath) {
            
            self.drawScreen.mainPath = bezierPath;
        }
    }
    

    
    
    [self.view addSubview:self.drawScreen];
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeSystem];
    doneButton.frame = CGRectMake(255, 10, 55, 44);
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
-(BOOL)prefersStatusBarHidden {
    
    return YES;
}

- (void)done
{
    
        NSString * docsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString * path = [docsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"textNoteDrawing_%i",activeNote]];
        
        NSData *bezierData = [NSKeyedArchiver archivedDataWithRootObject:self.drawScreen.mainPath];
        [bezierData writeToFile:path atomically:YES];
   
        
    [self.delegate flipsideViewControllerDidFinishWithView:activeNote];
}

-(void)dealloc
{
	_delegate  = nil;
    [_drawScreen release];
	[super dealloc];
}
@end
