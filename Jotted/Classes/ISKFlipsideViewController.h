//
//  ISKFlipsideViewController.h
//  IndexStack
//
//  Created by Alexey Linkov on 9/1/12.
//  Copyright (c) 2012 Alexey Linkov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ISKFlipsideViewController;

@protocol ISKFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinishWithView:(int)aView;
@end

@interface ISKFlipsideViewController : UIViewController

@property (assign, nonatomic) id <ISKFlipsideViewControllerDelegate> delegate;
@property int activeNote;

- (void)done;

@end
