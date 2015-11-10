//
//  UIFaceGestureBothEyesAreClosed.m
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 8/6/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import "UIFaceGestureBothEyesAreClosed.h"
#import "UIFaceGestureDetector.h"

@implementation UIFaceGestureBothEyesAreClosed

#pragma mark - Init
- (id)initWithTarget:(id)target action:(SEL)action repeatInterval:(NSTimeInterval)repeatInterval
{
    self = [super initWithTarget:target action:action repeatInterval:repeatInterval];
    if (self) {
        // nothing
    }
    return self;
}

- (id)initWithTarget:(id)target action:(SEL)action repeatInterval:(NSTimeInterval)repeatInterval cutoffTime:(NSTimeInterval)cutoffTime
{
    self = [super initWithTarget:target action:action repeatInterval:repeatInterval cutoffTime:cutoffTime];
    if (self) {
        // nothing
    }
    return self;
}

#pragma mark - UIFaceGestureSubscriber
-(void)bothEyesDidClose
{
    if ([self enabled]) {
        self.inAction = YES;
        self.closeStartTime = [self currentTime];
        [self startSendingActionsAfterCutoffIfEyeDetectorStateStill:@selector(rightEyeClosed)];
    }
}

-(void)bothEyesDidOpen
{
    self.inAction = NO;
    self.inRepeatingMode = NO;
}

-(void)rightEyeDidClose
{
    self.inAction = NO;
    self.inRepeatingMode = NO;
}

-(void)rightEyeDidOpen
{
    self.inAction = NO;
    self.inRepeatingMode = NO;
}

 -(void)leftEyeDidClose
 {
 self.inAction = NO;
 self.inRepeatingMode = NO;
 }

-(void)leftEyeDidOpen
{
    self.inAction = NO;
    self.inRepeatingMode = NO;
}

-(void)eyesLost
{
    self.inAction = NO;
    self.inRepeatingMode = NO;
}

@end
