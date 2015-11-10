//
//  UIFaceGestureLeftEyeDidWink.m
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 8/3/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import "UIFaceGestureLeftEyeDidWink.h"
#import "UIFaceGestureEyesSettings.h"

@implementation UIFaceGestureLeftEyeDidWink

- (id)initWithTarget:(id)target action:(SEL)action
{
    self = [super initWithTarget:target action:action];
    if (self) {
        self.intervalStart = [[UIFaceGestureEyesSettings sharedSettings] eyeWinkIntervalStart];
        self.intervalEnd = [[UIFaceGestureEyesSettings sharedSettings] eyeWinkIntervalEnd];
    }
    
    return self;
}

#pragma mark - UIFaceGestureSubscriber
-(void)leftEyeDidClose
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

-(void)bothEyesDidClose
{
    self.inAction = NO;
}

-(void)rightEyeDidOpen
{
    self.inAction = NO;
}

-(void)rightEyeDidClose
{
    self.inAction = NO;
}

-(void)leftEyeDidOpen
{
    if ([self enabled] && [self inAction]
        && [self timeElapsedFromGestureStartIsInInterval])
    {
        [self sendAction];
    }
}

@end
