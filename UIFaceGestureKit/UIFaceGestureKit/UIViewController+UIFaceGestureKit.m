//
//  UIViewController+UIFaceGestureKit.m
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 12/08/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import "UIViewController+UIFaceGestureKit.h"
#import <QuartzCore/QuartzCore.h>
#import "UIFaceGestureKitEyeGestures.h"
#import <objc/runtime.h>

@interface UIFaceGestureKitUIViewControllerMemento : NSObject
@property (nonatomic, strong) NSMutableSet* faceGestures;
@property (nonatomic) BOOL faceInteractionEnabled;

// eye scrolling
@property (nonatomic) BOOL eyeScrollingEnabled;
@property (nonatomic, strong) NSMutableArray* eyeScrolledViewSequence;
@property (nonatomic) NSInteger eyeScrolledViewSequenceCurrentIndex;
@property (nonatomic, strong) UIFaceGestureRightEyeIsClosed* eyeScrollingRightIsClosed;
@property (nonatomic, strong) UIFaceGestureRightEyeDidWink* eyeScrollingRightDidWink;
@property (nonatomic, strong) UIFaceGestureLeftEyeIsClosed* eyeScrollingLeftIsClosed;
@property (nonatomic, strong) UIFaceGestureLeftEyeDidWink* eyeScrollingLeftDidWink;
@property (nonatomic, strong) UIColor* eyeScrolledColor;
@property (nonatomic) CGFloat eyeScrolledBorderWidth;
@property (nonatomic) NSTimeInterval eyeScrollDelay;
@property (nonatomic) NSTimeInterval eyeScrollCutoff;

// eye selection
@property (nonatomic) BOOL eyeSelectionEnabled;
@property (nonatomic, strong) UIFaceGestureBothEyesDidWink* eyeSelectionBothDidClose;
@property (nonatomic, assign) NSObject<UIViewControllerFaceSelectionDelegate>* eyeSelectionDelegate;

@end

@implementation UIFaceGestureKitUIViewControllerMemento

-(id)init
{
    self = [super init];
    if (self) {
        _eyeScrollDelay = (NSTimeInterval)0.6;
        _eyeScrollCutoff = (NSTimeInterval)0.6;
        _eyeScrolledColor = [UIColor blueColor];
        _eyeScrolledBorderWidth = 3.0f;
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

static void *UIFaceGestureKitUIViewControllerMementoKey;

@implementation UIViewController (UIFaceGestureKit)

- (UIFaceGestureKitUIViewControllerMemento *)faceGestureKitUIViewControllerMemento
{
    UIFaceGestureKitUIViewControllerMemento* faceGestureKitUIViewControllerMemento = objc_getAssociatedObject(self, UIFaceGestureKitUIViewControllerMementoKey);
    if (!faceGestureKitUIViewControllerMemento) {
        faceGestureKitUIViewControllerMemento = [[UIFaceGestureKitUIViewControllerMemento alloc] init];
        objc_setAssociatedObject(self, UIFaceGestureKitUIViewControllerMementoKey, faceGestureKitUIViewControllerMemento, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return faceGestureKitUIViewControllerMemento;
}

#pragma mark Face gestures
-(void)addFaceGesture:(UIFaceGesture*)eyeGesture
{
    [[[self faceGestureKitUIViewControllerMemento] faceGestures] addObject:eyeGesture];
    if ([self faceInteractionEnabled]) {
        eyeGesture.enabled = YES;
    }
}

-(void)removeFaceGesture:(UIFaceGesture*)eyeGesture
{
    [[[self faceGestureKitUIViewControllerMemento] faceGestures] removeObject:eyeGesture];
    eyeGesture.enabled = NO;
}

-(void)setFaceInteractionEnabled:(BOOL)faceInteractionEnabled
{
    for (UIFaceGesture* gesture in [[self faceGestureKitUIViewControllerMemento] faceGestures]) {
        gesture.enabled = faceInteractionEnabled;
    }
    [self faceGestureKitUIViewControllerMemento].faceInteractionEnabled = faceInteractionEnabled;
}

-(BOOL)faceInteractionEnabled
{
    return [self faceGestureKitUIViewControllerMemento].faceInteractionEnabled;
}

#pragma mark - Eye interactive
-(BOOL)eyeScrollingEnabled
{
    return [self faceGestureKitUIViewControllerMemento].eyeScrollingEnabled;
}

-(void)setEyeScrollingEnabled:(BOOL)eyeScrollingEnabled
{
    if ([self eyeScrolledViewSequence] == nil || [self eyeScrolledViewSequence].count == 0) {
        TRC_ALT(@"You have set .eyeScrollingEnabled for %@, but eyeScrolledViewSequence is empty", NSStringFromClass([self class]));
    }
    
    if (![self eyeScrollingEnabled] && eyeScrollingEnabled) {
        [self faceGestureKitUIViewControllerMemento].eyeScrollingRightIsClosed = [[UIFaceGestureRightEyeIsClosed alloc] initWithTarget:self action:@selector(eyeGestureScrollToNextEyeSequenceView) repeatInterval:[self eyeScrollDelay] cutoffTime:[self eyeScrollCutoff]];
        [self addFaceGesture:[self faceGestureKitUIViewControllerMemento].eyeScrollingRightIsClosed];
        [self faceGestureKitUIViewControllerMemento].eyeScrollingRightIsClosed.enabled = YES;
        
        [self faceGestureKitUIViewControllerMemento].eyeScrollingRightDidWink = [[UIFaceGestureRightEyeDidWink alloc] initWithTarget:self action:@selector(eyeGestureScrollToNextEyeSequenceView)];
        [self addFaceGesture:[self faceGestureKitUIViewControllerMemento].eyeScrollingRightDidWink];
        [self faceGestureKitUIViewControllerMemento].eyeScrollingRightDidWink.enabled = YES;
        
        [self faceGestureKitUIViewControllerMemento].eyeScrollingLeftIsClosed = [[UIFaceGestureLeftEyeIsClosed alloc] initWithTarget:self action:@selector(eyeGestureScrollToPreviousEyeSequenceView) repeatInterval:[self eyeScrollDelay] cutoffTime:[self eyeScrollCutoff]];
        [self addFaceGesture:[self faceGestureKitUIViewControllerMemento].eyeScrollingLeftIsClosed];
        [self faceGestureKitUIViewControllerMemento].eyeScrollingLeftIsClosed.enabled = YES;
        
        [self faceGestureKitUIViewControllerMemento].eyeScrollingLeftDidWink = [[UIFaceGestureLeftEyeDidWink alloc] initWithTarget:self action:@selector(eyeGestureScrollToPreviousEyeSequenceView)];
        [self addFaceGesture:[self faceGestureKitUIViewControllerMemento].eyeScrollingLeftDidWink];
        [self faceGestureKitUIViewControllerMemento].eyeScrollingLeftDidWink.enabled = YES;
    } else if ([self eyeScrollingEnabled] && !eyeScrollingEnabled) {
        [self removeFaceGesture:[self faceGestureKitUIViewControllerMemento].eyeScrollingRightIsClosed];
        [self faceGestureKitUIViewControllerMemento].eyeScrollingRightIsClosed = nil;
        [self removeFaceGesture:[self faceGestureKitUIViewControllerMemento].eyeScrollingRightDidWink];
        [self faceGestureKitUIViewControllerMemento].eyeScrollingRightDidWink = nil;
        [self removeFaceGesture:[self faceGestureKitUIViewControllerMemento].eyeScrollingLeftIsClosed];
        [self faceGestureKitUIViewControllerMemento].eyeScrollingLeftIsClosed = nil;
        [self removeFaceGesture:[self faceGestureKitUIViewControllerMemento].eyeScrollingLeftDidWink];
        [self faceGestureKitUIViewControllerMemento].eyeScrollingLeftDidWink = nil;
    }
    [self faceGestureKitUIViewControllerMemento].eyeScrollingEnabled = eyeScrollingEnabled;
}

-(NSArray*)eyeScrolledViewSequence
{
    return [self faceGestureKitUIViewControllerMemento].eyeScrolledViewSequence;
}

-(void)setEyeScrolledViewSequence:(NSArray*)views
{
    [self faceGestureKitUIViewControllerMemento].eyeScrolledViewSequence = [NSMutableArray arrayWithArray:views];
    [self highlightCurrentEyeScrolledViewSequenceView];
}

-(void)eyeGestureScrollToPreviousEyeSequenceView
{
    [self deHighlightCurrentEyeScrolledViewSequenceView];
    [self decrementEyeScrolledViewSequenceCurrentIndex];
    [self highlightCurrentEyeScrolledViewSequenceView];
}

-(void)eyeGestureScrollToNextEyeSequenceView
{
    [self deHighlightCurrentEyeScrolledViewSequenceView];
    [self incrementEyeScrolledViewSequenceCurrentIndex];
    [self highlightCurrentEyeScrolledViewSequenceView];
}

-(void)deHighlightCurrentEyeScrolledViewSequenceView
{
    UIView* currentView = [[self faceGestureKitUIViewControllerMemento].eyeScrolledViewSequence objectAtIndex:[self faceGestureKitUIViewControllerMemento].eyeScrolledViewSequenceCurrentIndex];
    currentView.layer.borderWidth = 0.0f;
}

-(void)highlightCurrentEyeScrolledViewSequenceView
{
    UIView* currentView = [[self faceGestureKitUIViewControllerMemento].eyeScrolledViewSequence objectAtIndex:[self faceGestureKitUIViewControllerMemento].eyeScrolledViewSequenceCurrentIndex];
    currentView.layer.borderWidth = [self eyeScrolledBorderWidth];
    currentView.layer.borderColor = [self eyeScrolledColor].CGColor;
}

-(void)incrementEyeScrolledViewSequenceCurrentIndex
{
    NSInteger currentIndex = [self faceGestureKitUIViewControllerMemento].eyeScrolledViewSequenceCurrentIndex;
    NSInteger lastIndex = [self faceGestureKitUIViewControllerMemento].eyeScrolledViewSequence.count - 1;
    if (currentIndex >= lastIndex) {
        currentIndex = 0;
    } else {
        currentIndex++;
    }
    [self faceGestureKitUIViewControllerMemento].eyeScrolledViewSequenceCurrentIndex = currentIndex;
}

-(void)decrementEyeScrolledViewSequenceCurrentIndex
{
    NSInteger currentIndex = [self faceGestureKitUIViewControllerMemento].eyeScrolledViewSequenceCurrentIndex;
    NSInteger lastIndex = [self faceGestureKitUIViewControllerMemento].eyeScrolledViewSequence.count - 1;
    if (currentIndex <= 0) {
        currentIndex = lastIndex;
    } else {
        currentIndex--;
    }
    [self faceGestureKitUIViewControllerMemento].eyeScrolledViewSequenceCurrentIndex = currentIndex;
}

-(NSTimeInterval)eyeScrollDelay
{
    return [self faceGestureKitUIViewControllerMemento].eyeScrollDelay;
}

-(void)setEyeScrollDelay:(NSTimeInterval)eyeScrollDelay
{
    [self faceGestureKitUIViewControllerMemento].eyeScrollingLeftIsClosed.repeatInterval = eyeScrollDelay;
    [self faceGestureKitUIViewControllerMemento].eyeScrollingRightIsClosed.repeatInterval = eyeScrollDelay;
    [self faceGestureKitUIViewControllerMemento].eyeScrollDelay = eyeScrollDelay;
}

-(NSTimeInterval)eyeScrollCutoff
{
    return [self faceGestureKitUIViewControllerMemento].eyeScrollCutoff;
}

-(void)setEyeScrollCutoff:(NSTimeInterval)eyeScrollCutoff
{
    [self faceGestureKitUIViewControllerMemento].eyeScrollingLeftIsClosed.cutoffTime = eyeScrollCutoff;
    [self faceGestureKitUIViewControllerMemento].eyeScrollingRightIsClosed.cutoffTime = eyeScrollCutoff;
    [self faceGestureKitUIViewControllerMemento].eyeScrollCutoff = eyeScrollCutoff;
}

-(UIColor*)eyeScrolledColor{
    return [self faceGestureKitUIViewControllerMemento].eyeScrolledColor;
}

-(void)setEyeScrolledColor:(UIColor *)eyeScrolledColor
{
    [self faceGestureKitUIViewControllerMemento].eyeScrolledColor = eyeScrolledColor;
}

-(CGFloat)eyeScrolledBorderWidth
{
    return [self faceGestureKitUIViewControllerMemento].eyeScrolledBorderWidth;
}

-(void)setEyeScrolledBorderWidth:(CGFloat)eyeScrolledBorderWidth
{
    [self faceGestureKitUIViewControllerMemento].eyeScrolledBorderWidth = eyeScrolledBorderWidth;
}

#pragma mark - Eye selection
-(BOOL)eyeSelectionEnabled
{
    return [self faceGestureKitUIViewControllerMemento].eyeSelectionEnabled;
}

-(void)setEyeSelectionEnabled:(BOOL)eyeSelectionEnabled
{
    if ([self eyeScrolledViewSequence] == nil || [self eyeScrolledViewSequence].count == 0) {
        TRC_ALT(@"You have set .eyeSelectionEnabled for %@, but eyeScrolledViewSequence is empty", NSStringFromClass([self class]));
    }
    
    if (![self eyeSelectionEnabled] && eyeSelectionEnabled) {
        [self faceGestureKitUIViewControllerMemento].eyeSelectionBothDidClose = [[UIFaceGestureBothEyesDidWink alloc] initWithTarget:self action:@selector(eyeGestureSendSelectedToEyeSelectionDelegate)];
        [self addFaceGesture:[self faceGestureKitUIViewControllerMemento].eyeSelectionBothDidClose];
        [self faceGestureKitUIViewControllerMemento].eyeSelectionBothDidClose.enabled = YES;
    } else if ([self eyeSelectionEnabled] && !eyeSelectionEnabled) {
        [self removeFaceGesture:[self faceGestureKitUIViewControllerMemento].eyeSelectionBothDidClose];
        [self faceGestureKitUIViewControllerMemento].eyeSelectionBothDidClose = nil;
    }
}

-(NSObject<UIViewControllerFaceSelectionDelegate>*)eyeSelectionDelegate
{
    return [self faceGestureKitUIViewControllerMemento].eyeSelectionDelegate;
}

-(void)setEyeSelectionDelegate:(NSObject<UIViewControllerFaceSelectionDelegate> *)eyeSelectionDelegate
{
    [self faceGestureKitUIViewControllerMemento].eyeSelectionDelegate = eyeSelectionDelegate;
}


-(void)eyeGestureSendSelectedToEyeSelectionDelegate
{
    if ([self faceGestureKitUIViewControllerMemento].eyeSelectionDelegate) {
         UIView* currentView = [[self faceGestureKitUIViewControllerMemento].eyeScrolledViewSequence objectAtIndex:[self faceGestureKitUIViewControllerMemento].eyeScrolledViewSequenceCurrentIndex];
        [[self faceGestureKitUIViewControllerMemento].eyeSelectionDelegate viewController:self didSelectView:currentView byFaceGesture:[self faceGestureKitUIViewControllerMemento].eyeSelectionBothDidClose];
    }
}

@end
