//
//  UIScrollView+UIFaceGestureKit.h
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 17/08/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIFaceGesture.h"

@protocol UIScrollViewFaceSelectionDelegate <NSObject>

-(void)scrollView:(UIScrollView*)scrollView didSelectVisibleRect:(CGRect)visibleRect byFaceGesture:(UIFaceGesture*)faceGesture;

@end

typedef NS_ENUM(NSInteger, UIScrollViewEyeScrollingDirection) {
    UIScrollViewEyeScrollingDirectionHorizontal,
    UIScrollViewEyeScrollingDirectionVertical
};

@interface UIScrollView (UIFaceGestureKit)
@property (nonatomic) BOOL faceInteractionEnabled;

// eye scrolling
@property (nonatomic) BOOL eyeScrollingEnabled;
@property (nonatomic) UIScrollViewEyeScrollingDirection eyeScrollingDirection;
@property (nonatomic) CGFloat eyeScrollOffset;
@property (nonatomic) NSTimeInterval eyeScrollingDelay;
@property (nonatomic) NSTimeInterval eyeScrollingCutoff;

// eye selection
@property (nonatomic) BOOL eyeSelectionEnabled;
@property (nonatomic, assign) NSObject<UIScrollViewFaceSelectionDelegate>* eyeSelectionDelegate;

@end
