//
//  UIFaceGestureRightEyeDidOpen.m
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 8/3/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import "UIFaceGestureRightEyeDidOpen.h"

@implementation UIFaceGestureRightEyeDidOpen

-(void)rightEyeDidOpen
{
    if ([self enabled]) {
        [self sendAction];
    }
}

@end
