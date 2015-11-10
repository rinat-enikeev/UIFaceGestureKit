//
//  UIEyeGestureContinousLeftClosed.h
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 8/3/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIFaceGestureContinous.h"

// it is a continous gesture, meaning action is sending while eye is closed
@interface UIFaceGestureLeftEyeIsClosed : UIFaceGestureContinous

// Valid action method signatures:
//     -(void)handleGesture;
- (id)initWithTarget:(id)target action:(SEL)action repeatInterval:(NSTimeInterval)repeatInterval;
- (id)initWithTarget:(id)target action:(SEL)action repeatInterval:(NSTimeInterval)repeatInterval cutoffTime:(NSTimeInterval)cutoffTime;

@end
