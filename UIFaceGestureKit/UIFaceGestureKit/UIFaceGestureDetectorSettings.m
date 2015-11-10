//
//  UIFaceGestureDetectorSettings.m
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 7/29/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import "UIFaceGestureDetectorSettings.h"
#import "AVVideoSteamSource.h"


@implementation UIFaceGestureDetectorSettings

#pragma mark - Singleton
static UIFaceGestureDetectorSettings *sharedInstance = nil;

+ (UIFaceGestureDetectorSettings *)sharedSettings
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
-(NSString*)detectorAccuracy
{
    return CIDetectorAccuracyLow;
}
@end
