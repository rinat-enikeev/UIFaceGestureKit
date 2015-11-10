//
//  UIFaceGestureContinous.h
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 8/3/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIFaceGesture.h"

@interface UIFaceGestureContinous : UIFaceGesture // abstract
@property (nonatomic, readonly) BOOL inRepeatingMode;
@property NSTimeInterval cutoffTime;
@property NSTimeInterval repeatInterval;


// Valid action method signatures:
//     -(void)handleGesture;
- (id)initWithTarget:(id)target action:(SEL)action repeatInterval:(NSTimeInterval)repeatInterval;
- (id)initWithTarget:(id)target action:(SEL)action repeatInterval:(NSTimeInterval)repeatInterval cutoffTime:(NSTimeInterval)cutoffTime;

@end

@interface UIFaceGestureContinous ()
@property (nonatomic) BOOL inAction;
@property (nonatomic) BOOL inRepeatingMode;
@property (strong, nonatomic) NSTimer *repeatTimer;
@property (nonatomic) uint64_t closeStartTime;
@property (nonatomic) NSTimeInterval eyeDetectorStateCheckInterval;
@property (strong, nonatomic) NSTimer *checkingTimer;

-(void)startSendingActionsAfterCutoffIfEyeDetectorStateStill:(SEL)eyeDetectorCheckSelector;
-(uint64_t)currentTime;
@end
