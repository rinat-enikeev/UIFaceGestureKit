//
//  UIFaceGestureRightEyeDidClose.m
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 8/6/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import "UIFaceGestureRightEyeDidClose.h"

@implementation UIFaceGestureRightEyeDidClose

-(void)rightEyeDidClose
{
    if ([self enabled]) {
        [self sendAction];
    }
}

@end
