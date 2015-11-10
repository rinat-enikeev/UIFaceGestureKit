//
//  UIFaceGestureSmileDetected.m
//  UIFaceGestureDetector
//
//  Created by Rinat Enikeev on 8/5/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import "UIFaceGestureSmileDetected.h"

@implementation UIFaceGestureSmileDetected

-(void)smileDetected
{
    if ([self enabled]) {
        [self sendAction];
    }
}

@end
