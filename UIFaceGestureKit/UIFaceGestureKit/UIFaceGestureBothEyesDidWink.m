//
//  UIFaceGestureBothEyesDidWink.m
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 8/2/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import "UIFaceGestureBothEyesDidWink.h"
#import "UIFaceGestureEyesSettings.h"

@implementation UIFaceGestureBothEyesDidWink
- (id)initWithTarget:(id)target action:(SEL)action
{
    self = [super initWithTarget:target action:action];
    if (self) {
        self.intervalStart = [[UIFaceGestureEyesSettings sharedSettings] bothEyesWinkIntervalStart];
        self.intervalEnd = [[UIFaceGestureEyesSettings sharedSettings] bothEyesWinkIntervalEnd];
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

-(void)rightEyeDidOpen
{
    self.inAction = NO;
}

-(void)leftEyeDidOpen
{
    self.inAction = NO;
}

-(void)bothEyesDidOpen
{
    if ([self enabled] && [self inAction]
            && [self timeElapsedFromGestureStartIsInInterval])
    {
        [self sendAction];
    }
}

@end
