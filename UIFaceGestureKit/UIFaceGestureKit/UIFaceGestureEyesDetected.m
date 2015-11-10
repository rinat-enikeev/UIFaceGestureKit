//
//  UIFaceGestureEyesDetected.m
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 8/2/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import "UIFaceGestureEyesDetected.h"

@implementation UIFaceGestureEyesDetected 

-(void)eyesDetected
{
    if ([self enabled]) {
        [self sendAction];
    }
}

@end
