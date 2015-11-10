//
//  UIFaceGestureEyesSettings.h
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 8/2/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIFaceGestureEyesSettings : NSObject

+ (UIFaceGestureEyesSettings *)sharedSettings;

-(NSTimeInterval)eyeWinkIntervalStart;
-(NSTimeInterval)eyeWinkIntervalEnd;

-(NSTimeInterval)bothEyesWinkIntervalStart;
-(NSTimeInterval)bothEyesWinkIntervalEnd;

-(NSTimeInterval)eyeContinousGestureCutoffDefault;
-(NSTimeInterval)eyeContinousGestureRepeatIntervalDefault;
-(NSTimeInterval)eyeContinousGestureDetectorStateCheckIntervalDefault;

-(NSTimeInterval)bothEyesClosedThenOneEyeOpenIntervalStart;
-(NSTimeInterval)bothEyesClosedThenOneEyeOpenIntervalEnd;

@end
