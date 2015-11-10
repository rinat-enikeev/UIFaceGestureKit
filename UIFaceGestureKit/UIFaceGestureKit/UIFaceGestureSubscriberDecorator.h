//
//  UIFaceGestureSubscriberDecorator.h
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 7/21/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//
//  Decorates subscribers with ivars needed for processing.
//

#import <Foundation/Foundation.h>
#import "UIFaceGestureDetector.h"

@interface UIFaceGestureSubscriberDecorator : NSObject<UIFaceGestureSubscriber>

-(id)initWithFaceGestureSubscriber:(NSObject<UIFaceGestureSubscriber>*)subscriber;
-(NSObject<UIFaceGestureSubscriber>*)subscriber;

-(BOOL)respondsToEyeGestures;

-(BOOL)respondsToEyesDetected;
-(BOOL)respondsToEyesLost;

-(BOOL)respondsToRightEyeDidOpen;
-(BOOL)respondsToRightEyeDidClose;

-(BOOL)respondsToLeftEyeDidOpen;
-(BOOL)respondsToLeftEyeDidClose;

-(BOOL)respondsToBothEyesDidOpen;
-(BOOL)respondsToBothEyesDidClose;

-(BOOL)respondsToSmileGestures;

-(BOOL)respondsToSmileDetected;
-(BOOL)respondsToSmileLost;

@end
