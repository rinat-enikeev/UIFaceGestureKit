//
//  UIFaceGesture.m
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 8/5/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import "UIFaceGesture.h"
#import "UIFaceGestureDetector.h"

@interface UIFaceGesture()<UIFaceGestureSubscriber>

@end

@implementation UIFaceGesture

- (id)initWithTarget:(id)target action:(SEL)action
{
    self = [super init];
    if (self) {
        self.target = target;
        self.action = action;
    }
    
    return self;
    
}

-(void)setEnabled:(BOOL)enabled
{
    if (_enabled && !enabled) {
        [[UIFaceGestureDetector sharedDetector] removeSubscriber:self];
    } else if (!_enabled && enabled) {
        [[UIFaceGestureDetector sharedDetector] addSubscriber:self];
    }
    _enabled = enabled;
}

- (void)sendAction
{
    IMP imp = [[self target] methodForSelector:[self action]];
    void (*func)(id, SEL) = (void *)imp;
    func([self target], [self action]);
}

@end
