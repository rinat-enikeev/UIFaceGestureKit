//
//  UIFaceGestureContinous.m
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 8/3/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import "UIFaceGestureContinous.h"
#import "UIFaceGestureEyesSettings.h"
#import "UIFaceGestureDetector.h"
#import <mach/mach_time.h>

@interface UIFaceGestureContinous ()
@property (nonatomic) mach_timebase_info_data_t timeBaseInfo;
@end

@implementation UIFaceGestureContinous

- (id)initWithTarget:(id)target action:(SEL)action
{
    self = [super initWithTarget:target action:action];
    if (self) {
        self.cutoffTime = [[UIFaceGestureEyesSettings sharedSettings] eyeContinousGestureCutoffDefault];
        self.repeatInterval = [[UIFaceGestureEyesSettings sharedSettings] eyeContinousGestureRepeatIntervalDefault];
        self.eyeDetectorStateCheckInterval = [[UIFaceGestureEyesSettings sharedSettings] eyeContinousGestureDetectorStateCheckIntervalDefault];
        mach_timebase_info(&_timeBaseInfo);
    }
    
    return self;
}

- (id)initWithTarget:(id)target action:(SEL)action repeatInterval:(NSTimeInterval)interval
{
    self = [super initWithTarget:target action:action];
    if (self) {
        self.cutoffTime = [[UIFaceGestureEyesSettings sharedSettings] eyeWinkIntervalStart];
        self.repeatInterval = interval;
        self.eyeDetectorStateCheckInterval = [[UIFaceGestureEyesSettings sharedSettings] eyeContinousGestureDetectorStateCheckIntervalDefault];
        mach_timebase_info(&_timeBaseInfo);
    }
    return self;
}

- (id)initWithTarget:(id)target action:(SEL)action repeatInterval:(NSTimeInterval)repeatInterval cutoffTime:(NSTimeInterval)cutoffTime
{
    self = [super initWithTarget:target action:action];
    if (self) {
        self.cutoffTime = cutoffTime;
        self.repeatInterval = repeatInterval;
        self.eyeDetectorStateCheckInterval = [[UIFaceGestureEyesSettings sharedSettings] eyeContinousGestureDetectorStateCheckIntervalDefault];
        mach_timebase_info(&_timeBaseInfo);
    }
    return self;
}

-(void)setInRepeatingMode:(BOOL)inRepeatingMode
{
    if (![self inRepeatingMode] && inRepeatingMode) {
        [self sendAction];
        self.repeatTimer = [NSTimer scheduledTimerWithTimeInterval:[self repeatInterval] target:self selector:@selector(sendAction) userInfo:nil repeats:YES];
    } else if ([self inRepeatingMode] && !inRepeatingMode) {
        [[self checkingTimer] invalidate];
        self.checkingTimer = nil;
        [self.repeatTimer invalidate];
        self.repeatTimer = nil;
    }
    _inRepeatingMode = inRepeatingMode;
}

-(BOOL)timeElapsedFromGestureStartIsGreaterThanСutoff
{
    uint64_t endTime = mach_absolute_time();
    uint64_t elapsedTime = endTime - [self closeStartTime];
    uint64_t elapsedTimeNano = elapsedTime * [self timeBaseInfo].numer / [self timeBaseInfo].denom;
    uint64_t cutoffTimeNano = [self cutoffTime] * NSEC_PER_SEC;
    return (elapsedTimeNano > cutoffTimeNano);
}


-(void)startSendingActionsAfterCutoffIfEyeDetectorStateStill:(SEL)eyeDetectorCheckSelector
{
    self.checkingTimer = [NSTimer scheduledTimerWithTimeInterval:[self eyeDetectorStateCheckInterval
                                                                  ] target:self selector:@selector(startSendingActionsIf:) userInfo:NSStringFromSelector(eyeDetectorCheckSelector) repeats:YES];
}

-(void)startSendingActionsIf:(NSTimer*)theTimer
{
    if ([self inAction]) {
        SEL checkSelector = NSSelectorFromString((NSString*)[theTimer userInfo]);
        IMP imp = [[UIFaceGestureDetector sharedDetector] methodForSelector:checkSelector];
        BOOL (*func)(id, SEL) = (void *)imp;
        BOOL stillCorrectEyeDetectorState = func([UIFaceGestureDetector sharedDetector], checkSelector);
        
        if (stillCorrectEyeDetectorState) {
            if ([self timeElapsedFromGestureStartIsGreaterThanСutoff]) {
                [[self checkingTimer] invalidate];
                self.checkingTimer = nil;
                self.inRepeatingMode = YES;
            }
        } else {
            self.inAction = NO;
            [[self checkingTimer] invalidate];
            self.checkingTimer = nil;
            [self.repeatTimer invalidate];
            self.repeatTimer = nil;
        }
    } else {
        
        [[self checkingTimer] invalidate];
        self.checkingTimer = nil;
        [self.repeatTimer invalidate];
        self.repeatTimer = nil;
    }
    
}

-(uint64_t)currentTime
{
    return mach_absolute_time();
}

@end
