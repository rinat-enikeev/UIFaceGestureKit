//
//  UIFaceGestureTimed.h
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 8/3/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import "UIFaceGesture.h"

@interface UIFaceGestureTimed : UIFaceGesture // abstract

// specify interval in which gesture is handled
@property NSTimeInterval intervalStart;
@property NSTimeInterval intervalEnd;

// Valid action method signatures:
//     -(void)handleGesture;
- (id)initWithTarget:(id)target action:(SEL)action; // default initializer

@end

@interface UIFaceGestureTimed ()
@property (nonatomic) uint64_t gestureStartTime;
@property (nonatomic) BOOL inAction;
-(uint64_t)currentTime;
-(BOOL)timeElapsedFromGestureStartIsInInterval;
@end
