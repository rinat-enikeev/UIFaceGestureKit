//
//  UIViewController+UIFaceGestureKit.h
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 12/08/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIFaceGesture.h"

@protocol UIViewControllerFaceSelectionDelegate <NSObject>

-(void)viewController:(UIViewController*)viewController didSelectView:(UIView*)view byFaceGesture:(UIFaceGesture*)faceGesture;

@end

@interface UIViewController (UIFaceGestureKit)
@property (nonatomic) BOOL faceInteractionEnabled;

-(void)addFaceGesture:(UIFaceGesture*)eyeGesture;
-(void)removeFaceGesture:(UIFaceGesture*)eyeGesture;

// eye scrolling
@property (nonatomic) BOOL eyeScrollingEnabled;
@property (nonatomic, strong) NSArray* eyeScrolledViewSequence;
@property (nonatomic, strong) UIColor* eyeScrolledColor;
@property (nonatomic) CGFloat eyeScrolledBorderWidth;
@property (nonatomic) NSTimeInterval eyeScrollDelay;
@property (nonatomic) NSTimeInterval eyeScrollCutoff;

// eye selection
@property (nonatomic) BOOL eyeSelectionEnabled;
@property (nonatomic, assign) NSObject<UIViewControllerFaceSelectionDelegate>* eyeSelectionDelegate;

@end
