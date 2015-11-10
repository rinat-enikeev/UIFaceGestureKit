//
//  UIEyeGestureContinousRightClosed.m
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 8/3/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import "UIFaceGestureRightEyeIsClosed.h"
#import "UIFaceGestureDetector.h"

@implementation UIFaceGestureRightEyeIsClosed

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
-(void)rightEyeDidClose
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

-(void)bothEyesDidClose
{
    self.inAction = NO;
    self.inRepeatingMode = NO;
}

-(void)rightEyeDidOpen
{
    self.inAction = NO;
    self.inRepeatingMode = NO;
}

/* Skip for best user experience
-(void)leftEyeDidClose
{
    self.inAction = NO;
    self.inRepeatingMode = NO;
}
*/

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
