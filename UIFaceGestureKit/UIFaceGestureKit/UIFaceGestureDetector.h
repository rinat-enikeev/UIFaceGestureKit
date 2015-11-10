//
//  UIFaceGestureDetector.h
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 7/21/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//
//  Detects eye gestures using front camera.
// 
#import <Foundation/Foundation.h>
#import "AVVideoSteamSource.h"

@protocol UIFaceGestureSubscriber<NSObject>
@optional

-(void)eyesDetected;
-(void)eyesLost;

-(void)leftEyeDidOpen;
-(void)leftEyeDidClose;

-(void)rightEyeDidOpen;
-(void)rightEyeDidClose;

-(void)bothEyesDidOpen;
-(void)bothEyesDidClose;

-(void)smileDetected;
-(void)smileLost;

@end

@interface UIFaceGestureDetector : NSObject<AVVideoSteamSourceSubscriber>

+(UIFaceGestureDetector *)sharedDetector;
-(void)addSubscriber:(NSObject<UIFaceGestureSubscriber> *)subscriber;
-(void)removeSubscriber:(NSObject<UIFaceGestureSubscriber> *)subscriber;

-(BOOL)rightEyeClosed;
-(BOOL)leftEyeClosed;
-(BOOL)bothEyesClosed;
-(BOOL)eyesDetected;
-(BOOL)smileDetected;

@end
