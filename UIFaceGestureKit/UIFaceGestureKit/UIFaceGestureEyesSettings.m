//
//  UIFaceGestureEyesSettings.m
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 8/2/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import "UIFaceGestureEyesSettings.h"

@implementation UIFaceGestureEyesSettings
#pragma mark - Singleton
static UIFaceGestureEyesSettings *sharedInstance = nil;

+ (UIFaceGestureEyesSettings *)sharedSettings
{
    @synchronized(self)
    {
        if (sharedInstance == NULL) {
            sharedInstance = [[self alloc] init];
        }
        
    }
    return sharedInstance;
}

#pragma mark - Settings
-(NSTimeInterval)eyeWinkIntervalStart
{
    return 0.3;
}

-(NSTimeInterval)eyeWinkIntervalEnd
{
    return 1.3;
}

-(NSTimeInterval)bothEyesWinkIntervalStart
{
    return 0.3;
}

-(NSTimeInterval)bothEyesWinkIntervalEnd
{
    return 1.3;
}

-(NSTimeInterval)eyeContinousGestureDetectorStateCheckIntervalDefault
{
    return 0.2;
}

-(NSTimeInterval)eyeContinousGestureCutoffDefault
{
    return 1.3;
}

-(NSTimeInterval)eyeContinousGestureRepeatIntervalDefault
{
    return 0.2;
}


-(NSTimeInterval)bothEyesClosedThenOneEyeOpenIntervalStart
{
    return 0.3;
}

-(NSTimeInterval)bothEyesClosedThenOneEyeOpenIntervalEnd
{
    return 1.3;
}

@end
