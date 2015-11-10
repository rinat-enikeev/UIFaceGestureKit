//
//  UIFaceGesture.h
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 8/5/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIFaceGesture : NSObject // abstract
@property (nonatomic) SEL action;
@property (strong, nonatomic) id target;
@property (nonatomic) BOOL enabled;

// Valid action method signatures:
//     -(void)handleGesture;
- (id)initWithTarget:(id)target action:(SEL)action;
- (void)sendAction;
@end
