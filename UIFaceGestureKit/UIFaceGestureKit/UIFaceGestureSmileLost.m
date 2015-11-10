//
//  UIFaceGestureSmileLost.m
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 8/6/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import "UIFaceGestureSmileLost.h"

@implementation UIFaceGestureSmileLost

-(void)smileLost
{
    if ([self enabled]) {
        [self sendAction];
    }
}

@end
