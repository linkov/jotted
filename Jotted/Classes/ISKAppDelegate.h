//
//  ISKAppDelegate.h
//  IndexStack
//
//  Created by Alexey Linkov on 9/1/12.
//  Copyright (c) 2012 Alexey Linkov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ISKStacksViewController.h"

@class ISKSimpleStackViewController;

@interface ISKAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ISKStacksViewController *mainViewController;

@end
