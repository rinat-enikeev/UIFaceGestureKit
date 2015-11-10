//
//  UIEyeKeyboard.m
//  UIEyeKit
//
//  Created by Rinat Enikeev on 7/26/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import "UIEyeKeyboardView.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>

@interface UIEyeKeyboardView ()
@end

@implementation UIEyeKeyboardView

- (void)awakeFromNib
{    
    // set corner radius
    for (UIView* subview in [self subviews]) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton* button = (UIButton*)subview;
            [button setBackgroundImage:[self imageFromColor:[UIColor colorWithWhite:0.7 alpha:0.5]]
                         forState:UIControlStateHighlighted];
            button.layer.cornerRadius = 5.0f;
            button.layer.masksToBounds = YES;
            [button addTarget:self action:@selector(playInputClick:) forControlEvents:UIControlEventTouchUpInside];

        }
    }
    
}

-(UIImage *)imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

-(void)playInputClick:(id)sender
{
    // should be changed to UIInputViewAudioFeedback, but not now. 
    AudioServicesPlaySystemSound(0x450);
}

@end
