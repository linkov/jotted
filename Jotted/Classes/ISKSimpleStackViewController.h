//
//  ISKMainViewController.h
//  IndexStack
//
//  Created by Alexey Linkov on 9/1/12.
//  Copyright (c) 2012 Alexey Linkov. All rights reserved.
//

#import "ISKFlipsideViewController.h"
#import "ISKRootView.h"
@class ISKStacksViewController;

@interface ISKSimpleStackViewController : UIViewController <ISKFlipsideViewControllerDelegate,UITextViewDelegate,UIAlertViewDelegate,UIScrollViewDelegate,UICollisionBehaviorDelegate,UIActionSheetDelegate>

- (id)initWithTags:(NSArray *)viewTags delegate:(ISKStacksViewController *)delegate;
-(void)animateUp;

@property (nonatomic,strong) ISKRootView *simpleNotepadStack;


@end
