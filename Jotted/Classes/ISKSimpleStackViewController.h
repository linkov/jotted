//
//  ISKMainViewController.h
//  IndexStack
//
//  Created by Alexey Linkov on 9/1/12.
//  Copyright (c) 2012 Alexey Linkov. All rights reserved.
//

#import "ISKFlipsideViewController.h"
#import "ISKRootView.h"

@interface ISKSimpleStackViewController : UIViewController <ISKFlipsideViewControllerDelegate,UITextViewDelegate,UIAlertViewDelegate,UIScrollViewDelegate>


@property (nonatomic,retain) ISKRootView *simpleNotepadStack;
@end
