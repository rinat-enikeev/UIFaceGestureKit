//
//  FGKSKeyboardViewController.m
//  UIFaceGestureKitShowcase
//
//  Created by Rinat Enikeev on 13/08/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import "FGKSKeyboardViewController.h"
#import "UIFaceGestureKit/UIFaceGestureKit.h"

@implementation FGKSKeyboardViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    [_textField setEyeKeyboardInput:YES];
}

- (IBAction)present:(id)sender {
    [[UIEyeKeyboard sharedKeyboard] presentKeyboardAnimated:YES];
}

- (IBAction)dismiss:(id)sender {
    [[UIEyeKeyboard sharedKeyboard] dismissKeyboardAnimated:YES];
}

@end
