//
//  main.m
//  IndexStack
//
//  Created by Alexey Linkov on 9/1/12.
//  Copyright (c) 2012 Alexey Linkov. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ISKAppDelegate.h"

int main(int argc, char *argv[])
{
    setenv("CLASSIC", "0", 1);
    
    @autoreleasepool {
                
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([ISKAppDelegate class]));
    }
}
