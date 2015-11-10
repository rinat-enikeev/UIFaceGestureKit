//
//  UIFaceGestureRightEyeDidWink.m
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 8/3/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import "UIFaceGestureRightEyeDidWink.h"
#import "UIFaceGestureEyesSettings.h"

@implementation UIFaceGestureRightEyeDidWink
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
-(void)rightEyeDidClose
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

-(void)leftEyeDidOpen
{
    self.inAction = NO;
}

-(void)leftEyeDidClose
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
