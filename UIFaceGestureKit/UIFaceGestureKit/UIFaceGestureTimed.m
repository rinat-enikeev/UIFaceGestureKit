//
//  UIFaceGestureTimed.m
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 8/3/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import "UIFaceGestureTimed.h"
#import <mach/mach_time.h>

@interface UIFaceGestureTimed ()
@property (nonatomic) mach_timebase_info_data_t timeBaseInfo;
@end

@implementation UIFaceGestureTimed

- (id)initWithTarget:(id)target action:(SEL)action
{
    self = [super initWithTarget:target action:action];
    if (self) {
        mach_timebase_info(&_timeBaseInfo);
    }
    return self;
}

-(BOOL)timeElapsedFromGestureStartIsInInterval
{
    uint64_t endTime = mach_absolute_time();
    uint64_t elapsedTime = endTime - [self gestureStartTime];
    uint64_t elapsedTimeNano = elapsedTime * [self timeBaseInfo].numer / [self timeBaseInfo].denom;
    uint64_t intervalStartNano = [self intervalStart] * NSEC_PER_SEC;
    uint64_t intervalEndNano = [self intervalEnd] * NSEC_PER_SEC;
    
    return elapsedTimeNano > intervalStartNano && elapsedTimeNano < intervalEndNano;
}

-(uint64_t)currentTime
{
    return mach_absolute_time();
}

@end
