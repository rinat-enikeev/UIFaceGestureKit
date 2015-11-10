//
//  UIFaceGestureBothEyesClosedThenRightDidOpen.m
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 8/1/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import "UIFaceGestureBothEyesClosedThenRightDidOpen.h"
#import "UIFaceGestureEyesSettings.h"

@implementation UIFaceGestureBothEyesClosedThenRightDidOpen

- (id)initWithTarget:(id)target action:(SEL)action
{
    self = [super initWithTarget:target action:action];
    if (self) {
        self.intervalStart = [[UIFaceGestureEyesSettings sharedSettings] bothEyesClosedThenOneEyeOpenIntervalStart];
        self.intervalEnd = [[UIFaceGestureEyesSettings sharedSettings] bothEyesClosedThenOneEyeOpenIntervalEnd];
    }
    
    return self;
}

#pragma mark - UIFaceGestureSubscriber
-(void)bothEyesDidClose
{
    if ([self enabled]) {
        self.inAction = YES;
        self.gestureStartTime = [self currentTime];
    }
}

-(void)bothEyesDidOpen
{
    self.inAction = NO;
}

-(void)leftEyeDidOpen
{
    self.inAction = NO;
}

-(void)rightEyeDidOpen
{
    if ([self enabled] && [self inAction]
        && [self timeElapsedFromGestureStartIsInInterval])
    {
        [self sendAction];
    }
}

@end