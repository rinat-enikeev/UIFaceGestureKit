//
//  UIEyeKeyboardIPadViewController.h
//  UIEyeKit
//
//  Created by Rinat Enikeev on 7/26/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UIEyeKeyboardType) {
    UIEyeKeyboardTypeCharacters,
    UIEyeKeyboardTypeDigits,
    UIEyeKeyboardTypeSharp
};

typedef NS_ENUM(NSInteger, UIEyeKeyboardLanguage) {
    UIEyeKeyboardLanguageEnglish,
    UIEyeKeyboardLanguageLocale
};

@interface UIEyeKeyboard : UIViewController
@property (strong, nonatomic) NSObject<UITextInput>* textInput;
@property (strong, nonatomic) UIColor* hightlightColor;

+(UIEyeKeyboard*)sharedKeyboard;
-(void)presentKeyboardAnimated:(BOOL)animated;
-(void)dismissKeyboardAnimated:(BOOL)animated;
-(void)setKeyboard:(UIEyeKeyboardType)keyboardType language:(UIEyeKeyboardLanguage)language;

@end
