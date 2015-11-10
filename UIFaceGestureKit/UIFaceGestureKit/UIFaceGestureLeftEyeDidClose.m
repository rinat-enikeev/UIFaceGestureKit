//
//  UIFaceGestureLeftEyeDidClose.m
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 8/6/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import "UIFaceGestureLeftEyeDidClose.h"

@implementation UIFaceGestureLeftEyeDidClose

-(void)leftEyeDidClose
{
    if ([self enabled]) {
        [self sendAction];
    }
}

@end
