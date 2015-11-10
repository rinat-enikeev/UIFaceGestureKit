//
//  AVVideoSteamSource.h
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 8/5/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>
#import <AVFoundation/AVFoundation.h>

@class AVVideoSteamSource;

@protocol AVVideoSteamSourceSubscriber
@optional
-(void)videoStreamSource:(AVVideoSteamSource*)videoStreamSource
           capturedImage:(CIImage*)image
           inOrientation:(NSNumber*)imageOrientation;

@end

@interface AVVideoSteamSource : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate>
+(AVVideoSteamSource *)sharedSource;
-(void)addSubscriber:(NSObject<AVVideoSteamSourceSubscriber> *)subscriber;
-(void)removeSubscriber:(NSObject<AVVideoSteamSourceSubscriber> *)subscriber;

-(BOOL)isUsingFrontFacingCamera;

@end
