//
//  AVVideoSteamSourceSettings.h
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 8/5/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CMTime.h>
@interface AVVideoSteamSourceSettings : NSObject

+ (AVVideoSteamSourceSettings *)sharedSettings;
-(CMTimeScale)frameRatePerSec;
-(NSString*)captureSessionPreset;
-(NSNumber*)pixelBufferFormat;
@end
