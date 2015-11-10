//
//  UIFaceGestureSubscriberDecorator.m
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 7/21/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import "UIFaceGestureSubscriberDecorator.h"

@interface UIFaceGestureSubscriberDecorator ()
@property (nonatomic, strong) NSObject<UIFaceGestureSubscriber>* subscriber;
@property (nonatomic) BOOL respondsToEyesDetected;
@property (nonatomic) BOOL respondsToEyesLost;
@property (nonatomic) BOOL respondsToRightEyeDidOpen;
@property (nonatomic) BOOL respondsToRightEyeDidClose;
@property (nonatomic) BOOL respondsToLeftEyeDidOpen;
@property (nonatomic) BOOL respondsToLeftEyeDidClose;
@property (nonatomic) BOOL respondsToBothEyesDidOpen;
@property (nonatomic) BOOL respondsToBothEyesDidClose;
@property (nonatomic) BOOL respondsToSmileDetected;
@property (nonatomic) BOOL respondsToSmileLost;
@end

@implementation UIFaceGestureSubscriberDecorator

-(id)initWithFaceGestureSubscriber:(NSObject<UIFaceGestureSubscriber>*)subscriber
{
    self = [super init];
    if (self) {
        self.subscriber = subscriber;
        self.respondsToEyesDetected     = [_subscriber respondsToSelector:@selector(eyesDetected)];
        self.respondsToEyesLost         = [_subscriber respondsToSelector:@selector(eyesLost)];
        self.respondsToRightEyeDidOpen  = [_subscriber respondsToSelector:@selector(rightEyeDidOpen)];
        self.respondsToRightEyeDidClose = [_subscriber respondsToSelector:@selector(rightEyeDidClose)];
        self.respondsToLeftEyeDidOpen   = [_subscriber respondsToSelector:@selector(leftEyeDidOpen)];
        self.respondsToLeftEyeDidClose  = [_subscriber respondsToSelector:@selector(leftEyeDidClose)];
        self.respondsToBothEyesDidOpen  = [_subscriber respondsToSelector:@selector(bothEyesDidOpen)];
        self.respondsToBothEyesDidClose = [_subscriber respondsToSelector:@selector(bothEyesDidClose)];
        self.respondsToSmileDetected    = [_subscriber respondsToSelector:@selector(smileDetected)];
        self.respondsToSmileLost        = [_subscriber respondsToSelector:@selector(smileLost)];
    }
    return self;
}

-(NSObject<UIFaceGestureSubscriber>*)subscriber
{
    return _subscriber;
}

-(BOOL)respondsToEyeGestures
{
    return     self.respondsToEyesDetected
            || self.respondsToEyesLost
            || self.respondsToRightEyeDidOpen
            || self.respondsToRightEyeDidClose
            || self.respondsToLeftEyeDidOpen
            || self.respondsToLeftEyeDidClose
            || self.respondsToBothEyesDidOpen
            || self.respondsToBothEyesDidClose;
}

-(BOOL)respondsToSmileGestures
{
    return self.respondsToSmileDetected || self.respondsToSmileLost;
}

@end
