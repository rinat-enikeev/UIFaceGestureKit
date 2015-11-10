//
//  UIFaceGestureLeftEyeDidOpen.m
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 8/3/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import "UIFaceGestureLeftEyeDidOpen.h"

@implementation UIFaceGestureLeftEyeDidOpen

-(void)leftEyeDidOpen
{
    if ([self enabled]) {
        [self sendAction];
    }
}

@end
