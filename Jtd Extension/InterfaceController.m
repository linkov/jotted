//
//  InterfaceController.m
//  Jtd Extension
//
//  Created by alex on 9/30/15.
//  Copyright © 2015 Alexey Linkov. All rights reserved.
//
@import WatchConnectivity;
#import "InterfaceController.h"

@interface InterfaceController() <WCSessionDelegate>
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *mainTextLabel;
@property WCSession *session;
@property (strong, nonatomic) IBOutlet WKInterfaceGroup *backgroupGroup;

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    self.session = [WCSession defaultSession];
    self.session.delegate = self;
    [self.session activateSession];
    [self.backgroupGroup setRelativeHeight:1.0 withAdjustment:0.2];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

-(void)session:(nonnull WCSession *)session didReceiveApplicationContext:(nonnull NSDictionary<NSString *,id> *)applicationContext {

    dispatch_async(dispatch_get_main_queue(), ^{

        UIColor *color = [InterfaceController colorFromHexString:applicationContext[@"colorcode"]];

        [self.mainTextLabel setTextColor:[UIColor blackColor]];
        [self.mainTextLabel setText:applicationContext[@"note"] ];
        [self.backgroupGroup setBackgroundColor:color];
    });

}

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}


@end



