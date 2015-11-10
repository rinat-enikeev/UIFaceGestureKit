//
//  UITextField+UIFaceGestureKit.m
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 14/08/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import "UITextField+UIFaceGestureKit.h"
#import "UIEyeKeyboard.h"
#import <objc/runtime.h>

@interface UIFaceGestureKitUITextFieldMemento : NSObject
@property (nonatomic) BOOL eyeKeyboardInput;
@end

@implementation UIFaceGestureKitUITextFieldMemento

@end


static void *UIFaceGestureKitUITextFieldMementoKey;

@implementation UITextField (UIFaceGestureKit)

#pragma mark - Memento
- (UIFaceGestureKitUITextFieldMemento *)faceGestureKitUITextFieldMemento
{
    UIFaceGestureKitUITextFieldMemento* faceGestureKitUITextFieldMemento = objc_getAssociatedObject(self, UIFaceGestureKitUITextFieldMementoKey);
    if (!faceGestureKitUITextFieldMemento) {
        faceGestureKitUITextFieldMemento = [[UIFaceGestureKitUITextFieldMemento alloc] init];
        objc_setAssociatedObject(self, UIFaceGestureKitUITextFieldMementoKey, faceGestureKitUITextFieldMemento, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return faceGestureKitUITextFieldMemento;
}

-(BOOL)eyeKeyboardInput
{
    return [self faceGestureKitUITextFieldMemento].eyeKeyboardInput;
}

-(void)setEyeKeyboardInput:(BOOL)eyeKeyboardInput
{
    if (![self eyeKeyboardInput] && eyeKeyboardInput) {
        UIView* dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        self.inputView = dummyView; // Hide default keyboard, but show blinking cursor. Use eyeKeyboard.
        [self addTarget:self action:@selector(showEyeKeyboard) forControlEvents:UIControlEventEditingDidBegin];
    } else if ([self eyeKeyboardInput] && !eyeKeyboardInput) {
        [self removeTarget:self action:@selector(showEyeKeyboard) forControlEvents:UIControlEventEditingDidBegin];
        self.inputView = nil;
    }
}

-(void)showEyeKeyboard
{
    [[UIEyeKeyboard sharedKeyboard] setTextInput:self];
    [[UIEyeKeyboard sharedKeyboard] presentKeyboardAnimated:YES];
}

@end
