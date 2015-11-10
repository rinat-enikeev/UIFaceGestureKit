//
//  UIEyeKeyboard.h
//  UIEyeKit
//
//  Created by Rinat Enikeev on 7/26/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIEyeKeyboardView : UIView

@property (strong, nonatomic) IBOutlet UIImageView *keyboardBackground;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *characterKeys;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *shiftButtons;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *sharpButtons;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *abcButtons;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *digitsButtons;
@property (strong, nonatomic) IBOutlet UIButton *returnButton;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;
@property (strong, nonatomic) IBOutlet UIButton *dismissButton;
@property (strong, nonatomic) IBOutlet UIButton *altLangButton;
@property (strong, nonatomic) IBOutlet UIButton *undoButton;
@property (strong, nonatomic) IBOutlet UIButton *redoButton;
@property (strong, nonatomic) IBOutlet UIButton *leftShiftButton;
@property (strong, nonatomic) IBOutlet UIButton *rightShiftButton;

@property (strong, nonatomic) NSString* keyboardCharacters;

@end
