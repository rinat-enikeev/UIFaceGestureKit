//
//  UIScrollView+UIFaceGestureKit.m
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 17/08/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import "UIScrollView+UIFaceGestureKit.h"
#import "UIFaceGestureKitEyeGestures.h"
#import <objc/runtime.h>

@interface  UIFaceGestureKitUIScrollViewMemento : NSObject
@property (nonatomic, strong) NSMutableSet* faceGestures;
@property (nonatomic) BOOL faceInteractionEnabled;

@property (nonatomic) BOOL eyeScrollingEnabled;
@property (nonatomic) NSTimeInterval eyeScrollingDelay;
@property (nonatomic) NSTimeInterval eyeScrollingCutoff;
@property (nonatomic) CGFloat eyeScrollOffset;
@property (nonatomic) UIScrollViewEyeScrollingDirection eyeScrollingDirection;
@property (strong, nonatomic) UIFaceGestureLeftEyeIsClosed* eyeGestureScrollToTopOrLeft;
@property (strong, nonatomic) UIFaceGestureRightEyeIsClosed* eyeGestureScrollToBottomOrRight;
@property (strong, nonatomic) UIFaceGestureLeftEyeDidWink* eyeGestureWinkScrollToTopOrLeft;
@property (strong, nonatomic) UIFaceGestureRightEyeDidWink* eyeGestureWinkScrollToBottomOrRight;

// eye selection
@property (nonatomic) BOOL eyeSelectionEnabled;
@property (nonatomic, strong) UIFaceGestureBothEyesDidWink* eyeSelectionBothDidClose;
@property (nonatomic, assign) NSObject<UIScrollViewFaceSelectionDelegate>* eyeSelectionDelegate;

@end

@implementation UIFaceGestureKitUIScrollViewMemento

-(id)init
{
    self = [super init];
    if (self) {
        self.eyeScrollingDelay  = (NSTimeInterval) 0.4; // default
        self.eyeScrollingCutoff = (NSTimeInterval) 0.4; // default
        self.eyeScrollOffset = (CGFloat) 500.0f;        // default
        self.eyeScrollingDirection = UIScrollViewEyeScrollingDirectionVertical;
    }
    return self;
}

-(NSMutableSet*)faceGestures
{
    if (_faceGestures == nil) {
        _faceGestures = [NSMutableSet set];
    }
    return _faceGestures;
}

-(void)dealloc
{
    for (UIFaceGesture* gesture in [self faceGestures]) {
        gesture.enabled = NO;
    }
}

@end

static void *UIFaceGestureKitUIScrollViewMementoKey;

@implementation UIScrollView (UIFaceGestureKit)

#pragma mark - Memento
- (UIFaceGestureKitUIScrollViewMemento *)faceGestureKitUIScrollViewMemento
{
    UIFaceGestureKitUIScrollViewMemento* faceGestureKitUICollectionViewMemento = objc_getAssociatedObject(self, UIFaceGestureKitUIScrollViewMementoKey);
    if (!faceGestureKitUICollectionViewMemento) {
        faceGestureKitUICollectionViewMemento = [[UIFaceGestureKitUIScrollViewMemento alloc] init];
        objc_setAssociatedObject(self, UIFaceGestureKitUIScrollViewMementoKey, faceGestureKitUICollectionViewMemento, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return faceGestureKitUICollectionViewMemento;
}


#pragma mark - FaceInteraction Common
-(BOOL)faceInteractionEnabled
{
    return [self faceGestureKitUIScrollViewMemento].faceInteractionEnabled;
}

-(void)setFaceInteractionEnabled:(BOOL)faceInteractionEnabled
{
    for (UIFaceGesture* gesture in [[self faceGestureKitUIScrollViewMemento] faceGestures]) {
        gesture.enabled = faceInteractionEnabled;
    }
    [self faceGestureKitUIScrollViewMemento].faceInteractionEnabled = faceInteractionEnabled;
}

#pragma mark Eye gestures management
-(void)addFaceGesture:(UIFaceGesture*)eyeGesture
{
    [[[self faceGestureKitUIScrollViewMemento] faceGestures] addObject:eyeGesture];
    if ([self faceInteractionEnabled]) {
        eyeGesture.enabled = YES;
    }
}

-(void)removeFaceGesture:(UIFaceGesture*)eyeGesture
{
    [[[self faceGestureKitUIScrollViewMemento] faceGestures] removeObject:eyeGesture];
    eyeGesture.enabled = NO;
}

#pragma mark Eye scrolling
-(BOOL)eyeScrollingEnabled
{
    return [self faceGestureKitUIScrollViewMemento].eyeScrollingEnabled;
}

-(void)setEyeScrollingEnabled:(BOOL)eyeScrollingEnabled
{
    if (![self eyeScrollingEnabled] && eyeScrollingEnabled) {
        
        [self faceGestureKitUIScrollViewMemento].eyeGestureScrollToTopOrLeft = [[UIFaceGestureLeftEyeIsClosed alloc] initWithTarget:self action:@selector(eyeGestureScrollToLeftOrTop) repeatInterval:[self eyeScrollingDelay] cutoffTime:[self eyeScrollingCutoff]];
        [self addFaceGesture:[self faceGestureKitUIScrollViewMemento].eyeGestureScrollToTopOrLeft];
        
        [self faceGestureKitUIScrollViewMemento].eyeGestureScrollToBottomOrRight = [[UIFaceGestureRightEyeIsClosed alloc] initWithTarget:self action:@selector(eyeGestureScrollToBottomOrRight) repeatInterval:[self eyeScrollingDelay]  cutoffTime:[self eyeScrollingCutoff]];
        [self addFaceGesture:[self faceGestureKitUIScrollViewMemento].eyeGestureScrollToBottomOrRight];
        
        [self faceGestureKitUIScrollViewMemento].eyeGestureWinkScrollToTopOrLeft = [[UIFaceGestureLeftEyeDidWink alloc] initWithTarget:self action:@selector(eyeGestureScrollToLeftOrTop)];
        [self addFaceGesture:[self faceGestureKitUIScrollViewMemento].eyeGestureWinkScrollToTopOrLeft];
        [self faceGestureKitUIScrollViewMemento].eyeGestureWinkScrollToBottomOrRight = [[UIFaceGestureRightEyeDidWink alloc] initWithTarget:self action:@selector(eyeGestureScrollToBottomOrRight)];
        [self addFaceGesture:[self faceGestureKitUIScrollViewMemento].eyeGestureWinkScrollToBottomOrRight ];
    } else if ([self eyeScrollingEnabled] && !eyeScrollingEnabled) {
        [self removeFaceGesture:[self faceGestureKitUIScrollViewMemento].eyeGestureScrollToTopOrLeft];
        [self faceGestureKitUIScrollViewMemento].eyeGestureScrollToTopOrLeft = nil;
        [self removeFaceGesture:[self faceGestureKitUIScrollViewMemento].eyeGestureScrollToBottomOrRight];
        [self faceGestureKitUIScrollViewMemento].eyeGestureScrollToBottomOrRight = nil;
        [self removeFaceGesture:[self faceGestureKitUIScrollViewMemento].eyeGestureWinkScrollToTopOrLeft];
        [self faceGestureKitUIScrollViewMemento].eyeGestureWinkScrollToTopOrLeft = nil;
        [self removeFaceGesture:[self faceGestureKitUIScrollViewMemento].eyeGestureWinkScrollToBottomOrRight];
        [self faceGestureKitUIScrollViewMemento].eyeGestureWinkScrollToBottomOrRight = nil;
    }
    [self faceGestureKitUIScrollViewMemento].eyeScrollingEnabled = eyeScrollingEnabled;
}

-(NSTimeInterval)eyeScrollingDelay
{
    return [self faceGestureKitUIScrollViewMemento].eyeScrollingDelay;
}

-(void)setEyeScrollingDelay:(NSTimeInterval)eyeScrollingDelay
{
    [self faceGestureKitUIScrollViewMemento].eyeGestureScrollToTopOrLeft.repeatInterval = eyeScrollingDelay;
    [self faceGestureKitUIScrollViewMemento].eyeGestureScrollToBottomOrRight.repeatInterval = eyeScrollingDelay;
    [self faceGestureKitUIScrollViewMemento].eyeScrollingDelay = eyeScrollingDelay;
}

-(NSTimeInterval)eyeScrollingCutoff
{
    return [self faceGestureKitUIScrollViewMemento].eyeScrollingCutoff;
}

-(void)setEyeScrollingCutoff:(NSTimeInterval)eyeScrollingCutoff
{
    [self faceGestureKitUIScrollViewMemento].eyeGestureScrollToTopOrLeft.cutoffTime = eyeScrollingCutoff;
    [self faceGestureKitUIScrollViewMemento].eyeGestureScrollToBottomOrRight.cutoffTime = eyeScrollingCutoff;
    [self faceGestureKitUIScrollViewMemento].eyeScrollingCutoff = eyeScrollingCutoff;
}


-(void)eyeGestureScrollToLeftOrTop
{
    if (([self faceInteractionEnabled])) {
        CGRect visibleRect = CGRectApplyAffineTransform(self.bounds, CGAffineTransformMakeScale(1.0 / self.zoomScale, 1.0 / self.zoomScale));
        
        if ([self eyeScrollingDirection] == UIScrollViewEyeScrollingDirectionVertical) {
            visibleRect.origin.y = visibleRect.origin.y - [self eyeScrollOffset];
            if (visibleRect.origin.y < 0) {
                visibleRect.origin.y = 0;
            }
        } else if ([self eyeScrollingDirection] == UIScrollViewEyeScrollingDirectionHorizontal) {
            visibleRect.origin.y = visibleRect.origin.x - [self eyeScrollOffset];
            if (visibleRect.origin.x < 0) {
                visibleRect.origin.x = 0;
            }
        }
        [self scrollRectToVisible:visibleRect animated:YES];
    }
}

-(void)eyeGestureScrollToBottomOrRight
{
    if ([self faceInteractionEnabled]) {
        CGRect visibleRect = CGRectApplyAffineTransform(self.bounds, CGAffineTransformMakeScale(1.0 / self.zoomScale, 1.0 / self.zoomScale));
        
        if ([self eyeScrollingDirection] == UIScrollViewEyeScrollingDirectionVertical) {
            visibleRect.origin.y = visibleRect.origin.y + [self eyeScrollOffset];
        } else if ([self eyeScrollingDirection] == UIScrollViewEyeScrollingDirectionHorizontal) {
            visibleRect.origin.y = visibleRect.origin.x + [self eyeScrollOffset];
        }

        [self scrollRectToVisible:visibleRect animated:YES];    }
}

-(CGFloat)eyeScrollOffset
{
    return [self faceGestureKitUIScrollViewMemento].eyeScrollOffset;
}

-(void)setEyeScrollOffset:(CGFloat)eyeScrollOffset
{
    [self faceGestureKitUIScrollViewMemento].eyeScrollOffset = eyeScrollOffset;
}

-(UIScrollViewEyeScrollingDirection)eyeScrollingDirection
{
    return [self faceGestureKitUIScrollViewMemento].eyeScrollingDirection;
}

-(void)setEyeScrollingDirection:(UIScrollViewEyeScrollingDirection)eyeScrollingDirection
{
    [self faceGestureKitUIScrollViewMemento].eyeScrollingDirection = eyeScrollingDirection;
}

#pragma mark - Eye selection
-(BOOL)eyeSelectionEnabled
{
    return [self faceGestureKitUIScrollViewMemento].eyeSelectionEnabled;
}

-(void)setEyeSelectionEnabled:(BOOL)eyeSelectionEnabled
{
    if (![self eyeSelectionEnabled] && eyeSelectionEnabled) {
        [self faceGestureKitUIScrollViewMemento].eyeSelectionBothDidClose = [[UIFaceGestureBothEyesDidWink alloc] initWithTarget:self action:@selector(eyeGestureSendSelectedToEyeSelectionDelegate)];
        [self addFaceGesture:[self faceGestureKitUIScrollViewMemento].eyeSelectionBothDidClose];
        [self faceGestureKitUIScrollViewMemento].eyeSelectionBothDidClose.enabled = YES;
    } else if ([self eyeSelectionEnabled] && !eyeSelectionEnabled) {
        [self removeFaceGesture:[self faceGestureKitUIScrollViewMemento].eyeSelectionBothDidClose];
        [self faceGestureKitUIScrollViewMemento].eyeSelectionBothDidClose = nil;
    }
}

-(NSObject<UIScrollViewFaceSelectionDelegate>*)eyeSelectionDelegate
{
    return [self faceGestureKitUIScrollViewMemento].eyeSelectionDelegate;
}

-(void)setEyeSelectionDelegate:(NSObject<UIScrollViewFaceSelectionDelegate> *)eyeSelectionDelegate
{
    [self faceGestureKitUIScrollViewMemento].eyeSelectionDelegate = eyeSelectionDelegate;
}


-(void)eyeGestureSendSelectedToEyeSelectionDelegate
{
    if ([self faceGestureKitUIScrollViewMemento].eyeSelectionDelegate) {
        CGRect visibleRect;
        visibleRect.origin = self.contentOffset;
        visibleRect.size = self.bounds.size;
        
        float theScale = 1.0 / self.zoomScale;
        visibleRect.origin.x *= theScale;
        visibleRect.origin.y *= theScale;
        visibleRect.size.width *= theScale;
        visibleRect.size.height *= theScale;
        
        [[self faceGestureKitUIScrollViewMemento].eyeSelectionDelegate scrollView:self didSelectVisibleRect:visibleRect byFaceGesture:[self faceGestureKitUIScrollViewMemento].eyeSelectionBothDidClose];
    }
}

@end
