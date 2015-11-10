//
//  AVVideoSteamSourceSettings.m
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 8/5/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import "AVVideoSteamSourceSettings.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@implementation AVVideoSteamSourceSettings

#pragma mark - Singleton
static AVVideoSteamSourceSettings *sharedInstance = nil;

+ (AVVideoSteamSourceSettings *)sharedSettings
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
-(CMTimeScale)frameRatePerSec
{
    return 5;
}

-(NSString*)captureSessionPreset
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
	    return AVCaptureSessionPreset640x480;
	} else {
	    return AVCaptureSessionPresetPhoto;
	}
}

-(NSNumber*)pixelBufferFormat
{
    return [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange];
}

@end
