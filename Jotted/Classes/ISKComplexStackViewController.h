//
//  ISKComplexStackViewController.h
//  Jotted
//
//  Created by linkov on 12/16/12.
//  Copyright (c) 2012 Alexey Linkov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ISKFlipsideViewController.h"
#import "ISKRootView.h"

@interface ISKComplexStackViewController : UIViewController <ISKFlipsideViewControllerDelegate,UITextViewDelegate,UIAlertViewDelegate,UIScrollViewDelegate>

@property (nonatomic,retain) ISKRootView *complexNotepadStack;
@property BOOL isVisible;
@end
