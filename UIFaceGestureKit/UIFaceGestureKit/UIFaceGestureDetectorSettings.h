//
//  UIFaceGestureDetectorSettings.h
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 7/29/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//
//  Device specific

#import <Foundation/Foundation.h>

@interface UIFaceGestureDetectorSettings : NSObject
+ (UIFaceGestureDetectorSettings *)sharedSettings;

-(NSString*)detectorAccuracy;

@end
