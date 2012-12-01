//
//  ISKNoteView.m
//  Jotted
//
//  Created by Alexey Linkov on 12/1/12.
//  Copyright (c) 2012 Alexey Linkov. All rights reserved.
//

#import "ISKNoteView.h"

@implementation ISKNoteView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius =STACKCORNERRAD;
    }
    return self;
}



@end
