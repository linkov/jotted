//
//  ISKStackIAPHelper.m
//  Jotted
//
//  Created by alex on 2/8/14.
//  Copyright (c) 2014 Alexey Linkov. All rights reserved.
//

#import "ISKStackIAPHelper.h"

@implementation ISKStackIAPHelper

+ (ISKStackIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static ISKStackIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"JOTTEDSTACK",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}


@end
