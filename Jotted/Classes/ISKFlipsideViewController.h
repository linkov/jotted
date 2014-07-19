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

@property (weak, nonatomic) id <ISKFlipsideViewControllerDelegate> delegate;

- (void)done;

-(id)initWithColor:(UIColor *)color noteTag:(int)noteTag delegate:(id)delegate;

@end
