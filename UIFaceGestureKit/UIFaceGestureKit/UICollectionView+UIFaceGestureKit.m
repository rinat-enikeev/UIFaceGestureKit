//
//  UICollectionView+UIFaceGestureKit.m
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 12/08/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import "UICollectionView+UIFaceGestureKit.h"
#import "UIFaceGestureKitEyeGestures.h"
#import <objc/runtime.h>

@interface  UIFaceGestureKitUICollectionViewMemento : NSObject
@property (nonatomic, strong) NSMutableSet* faceGestures;
@property (nonatomic) BOOL faceInteractionEnabled;

@property (nonatomic) BOOL eyeScrollingEnabled;
@property (nonatomic) NSTimeInterval eyeScrollingDelay;
@property (nonatomic) NSTimeInterval eyeScrollingCutoff;
@property (nonatomic) BOOL eyeScrollingCircle;
@property (nonatomic) UICollectionViewScrollPosition eyeScrollPosition;
@property (nonatomic) NSInteger eyeScrolledItemIndex;
@property (nonatomic) NSInteger eyeScrolledSection;

@property (strong, nonatomic) UIFaceGestureLeftEyeIsClosed* eyeGestureScrollToPreviousItem;
@property (strong, nonatomic) UIFaceGestureRightEyeIsClosed* eyeGestureScrollToNextItem;
@property (strong, nonatomic) UIFaceGestureLeftEyeDidWink* eyeGestureWinkScrollToPreviousItem;
@property (strong, nonatomic) UIFaceGestureRightEyeDidWink* eyeGestureWinkScrollToNextItem;

@property (nonatomic) BOOL eyeSelectionEnabled;
@property (strong, nonatomic) UIFaceGestureBothEyesDidWink* eyeGestureSendDidSelectToCurrentlySelectedItem;

@end

@implementation UIFaceGestureKitUICollectionViewMemento

-(id)init
{
    self = [super init];
    if (self) {
        self.eyeScrollingDelay  = (NSTimeInterval) 0.4; // default
        self.eyeScrollingCutoff = (NSTimeInterval) 0.4; // default
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

static void *UIFaceGestureKitUICollectionViewMementoKey;

@implementation UICollectionView (UIFaceGestureKit)

#pragma mark - Memento
- (UIFaceGestureKitUICollectionViewMemento *)faceGestureKitUICollectionViewMemento
{
    UIFaceGestureKitUICollectionViewMemento* faceGestureKitUICollectionViewMemento = objc_getAssociatedObject(self, UIFaceGestureKitUICollectionViewMementoKey);
    if (!faceGestureKitUICollectionViewMemento) {
        faceGestureKitUICollectionViewMemento = [[UIFaceGestureKitUICollectionViewMemento alloc] init];
        objc_setAssociatedObject(self, UIFaceGestureKitUICollectionViewMementoKey, faceGestureKitUICollectionViewMemento, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return faceGestureKitUICollectionViewMemento;
}

#pragma mark - FaceInteractionCommon
-(BOOL)faceInteractionEnabled
{
    return [self faceGestureKitUICollectionViewMemento].faceInteractionEnabled;
}

-(void)setFaceInteractionEnabled:(BOOL)faceInteractionEnabled
{
    for (UIFaceGesture* gesture in [[self faceGestureKitUICollectionViewMemento] faceGestures]) {
        gesture.enabled = faceInteractionEnabled;
    }
    [self faceGestureKitUICollectionViewMemento].faceInteractionEnabled = faceInteractionEnabled;
}

#pragma mark Eye gestures management
-(void)addFaceGesture:(UIFaceGesture*)faceGesture
{
    [[[self faceGestureKitUICollectionViewMemento] faceGestures] addObject:faceGesture];
    if ([self faceInteractionEnabled]) {
        faceGesture.enabled = YES;
    }
}

-(void)removeFaceGesture:(UIFaceGesture*)faceGesture
{
    [[[self faceGestureKitUICollectionViewMemento] faceGestures] removeObject:faceGesture];
    faceGesture.enabled = NO;
}

#pragma mark Eye scrolling
-(BOOL)eyeScrollingEnabled
{
    return [self faceGestureKitUICollectionViewMemento].eyeScrollingEnabled;
}

-(void)setEyeScrollingEnabled:(BOOL)eyeScrollingEnabled
{
    if (![self eyeScrollingEnabled] && eyeScrollingEnabled) {
        [self faceGestureKitUICollectionViewMemento].eyeGestureScrollToPreviousItem = [[UIFaceGestureLeftEyeIsClosed alloc] initWithTarget:self action:@selector(eyeGestureScrollToPreviousItemHandler) repeatInterval:[self faceGestureKitUICollectionViewMemento].eyeScrollingDelay cutoffTime:[self faceGestureKitUICollectionViewMemento].eyeScrollingCutoff];
        [self addFaceGesture:[self faceGestureKitUICollectionViewMemento].eyeGestureScrollToPreviousItem];
        
        [self faceGestureKitUICollectionViewMemento].eyeGestureScrollToNextItem = [[UIFaceGestureRightEyeIsClosed alloc] initWithTarget:self action:@selector(eyeGestureScrollToNextRowHandler) repeatInterval:[self faceGestureKitUICollectionViewMemento].eyeScrollingDelay cutoffTime:[self faceGestureKitUICollectionViewMemento].eyeScrollingCutoff];
        [self addFaceGesture:[self faceGestureKitUICollectionViewMemento].eyeGestureScrollToNextItem];
        
        [self faceGestureKitUICollectionViewMemento].eyeGestureWinkScrollToPreviousItem = [[UIFaceGestureLeftEyeDidWink alloc] initWithTarget:self action:@selector(eyeGestureScrollToPreviousItemHandler)];
        [self addFaceGesture:[self faceGestureKitUICollectionViewMemento].eyeGestureWinkScrollToPreviousItem];
        [self faceGestureKitUICollectionViewMemento].eyeGestureWinkScrollToNextItem = [[UIFaceGestureRightEyeDidWink alloc] initWithTarget:self action:@selector(eyeGestureScrollToNextRowHandler)];
        [self addFaceGesture:[self faceGestureKitUICollectionViewMemento].eyeGestureWinkScrollToNextItem];
    } else if ([self eyeScrollingEnabled] && !eyeScrollingEnabled) {
        [self removeFaceGesture:[self faceGestureKitUICollectionViewMemento].eyeGestureScrollToPreviousItem];
        [self faceGestureKitUICollectionViewMemento].eyeGestureScrollToPreviousItem = nil;
        [self removeFaceGesture:[self faceGestureKitUICollectionViewMemento].eyeGestureScrollToNextItem];
        [self faceGestureKitUICollectionViewMemento].eyeGestureScrollToNextItem = nil;
        [self removeFaceGesture:[self faceGestureKitUICollectionViewMemento].eyeGestureWinkScrollToNextItem];
        [self faceGestureKitUICollectionViewMemento].eyeGestureWinkScrollToNextItem = nil;
        [self removeFaceGesture:[self faceGestureKitUICollectionViewMemento].eyeGestureWinkScrollToPreviousItem];
        [self faceGestureKitUICollectionViewMemento].eyeGestureWinkScrollToPreviousItem = nil;
    }
    [self faceGestureKitUICollectionViewMemento].eyeScrollingEnabled = eyeScrollingEnabled;
}

-(void)eyeGestureScrollToPreviousItemHandler
{
    if ([self faceInteractionEnabled]) {
        BOOL currentItemIsFirstInFirstSection = [self faceGestureKitUICollectionViewMemento].eyeScrolledSection == 0
        && [self faceGestureKitUICollectionViewMemento].eyeScrolledItemIndex == 0;
        
        if (![self eyeScrollingCircle] && currentItemIsFirstInFirstSection) {
            // do not scroll
        } else {
            [self decrementSelectedItemIndex];
            [self eyeScrollingSelectItem:[self faceGestureKitUICollectionViewMemento].eyeScrolledItemIndex inSection:[self faceGestureKitUICollectionViewMemento].eyeScrolledSection];
        }
        
    }
}

-(void)eyeGestureScrollToNextRowHandler
{
    if ([self faceInteractionEnabled]) {
        BOOL currentItemIsLastInLastSection = [self faceGestureKitUICollectionViewMemento].eyeScrolledSection == [self numberOfSections] - 1
            && [self faceGestureKitUICollectionViewMemento].eyeScrolledItemIndex == [self numberOfItemsInSection:[self faceGestureKitUICollectionViewMemento].eyeScrolledSection] - 1;
        
        if (![self eyeScrollingCircle] && currentItemIsLastInLastSection) {
            // do not scroll
        } else {
            [self incremetSelectedItemIndex];
            [self eyeScrollingSelectItem:[self faceGestureKitUICollectionViewMemento].eyeScrolledItemIndex inSection:[self faceGestureKitUICollectionViewMemento].eyeScrolledSection];
        }
    }
}

-(void)incremetSelectedItemIndex
{
    NSInteger numberOfItemsInCurrentSection = [self numberOfItemsInSection:[self faceGestureKitUICollectionViewMemento].eyeScrolledSection];
    NSInteger numberOfSections = [self numberOfSections];
    NSInteger currentItemIndex = [self faceGestureKitUICollectionViewMemento].eyeScrolledItemIndex;
    NSInteger currentSection = [self faceGestureKitUICollectionViewMemento].eyeScrolledSection;
    
    BOOL currentItemIsLastInSection = (currentItemIndex == numberOfItemsInCurrentSection - 1);
    if (currentItemIsLastInSection) {
        if (currentSection < numberOfSections - 1) {
            currentSection++;
            currentItemIndex = 0;
        } else if (currentSection == numberOfSections - 1) {
            currentSection = 0;
            currentItemIndex = 0;
        }
    } else {
        currentItemIndex++;
    }
    
    [self faceGestureKitUICollectionViewMemento].eyeScrolledItemIndex = currentItemIndex;
    [self faceGestureKitUICollectionViewMemento].eyeScrolledSection = currentSection;
}

-(void)decrementSelectedItemIndex
{
    NSInteger numberOfSections = [self numberOfSections];
    NSInteger currentItemIndex = [self faceGestureKitUICollectionViewMemento].eyeScrolledItemIndex;
    NSInteger currentSection = [self faceGestureKitUICollectionViewMemento].eyeScrolledSection;
    
    BOOL currentItemsFirstInSection = currentItemIndex == 0;
    
    if (currentItemsFirstInSection) {
        if (currentSection == 0) {
            currentSection = numberOfSections - 1;
        } else {
            currentSection--;
        }
        currentItemIndex = [self numberOfItemsInSection:currentSection] - 1;
    } else {
        currentItemIndex--;
    }
    
    [self faceGestureKitUICollectionViewMemento].eyeScrolledItemIndex = currentItemIndex;
    [self faceGestureKitUICollectionViewMemento].eyeScrolledSection = currentSection;
}


- (void)eyeScrollingSelectItem:(NSInteger)itemIndex inSection:(NSInteger)section
{
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:itemIndex inSection:section];
    [self selectItemAtIndexPath:indexPath animated:YES scrollPosition:[self faceGestureKitUICollectionViewMemento].eyeScrollPosition];
}

-(NSTimeInterval)eyeScrollingDelay
{
    return [self faceGestureKitUICollectionViewMemento].eyeScrollingDelay;
}

-(void)setEyeScrollingDelay:(NSTimeInterval)eyeScrollingDelay
{
    [self faceGestureKitUICollectionViewMemento].eyeGestureScrollToPreviousItem.repeatInterval = eyeScrollingDelay;
    [self faceGestureKitUICollectionViewMemento].eyeGestureScrollToNextItem.repeatInterval = eyeScrollingDelay;
    [self faceGestureKitUICollectionViewMemento].eyeScrollingDelay = eyeScrollingDelay;
}

-(NSTimeInterval)eyeScrollingCutoff
{
    return [self faceGestureKitUICollectionViewMemento].eyeScrollingCutoff;
}

-(void)setEyeScrollingCutoff:(NSTimeInterval)eyeScrollingCutoff
{
    [self faceGestureKitUICollectionViewMemento].eyeGestureScrollToPreviousItem.cutoffTime = eyeScrollingCutoff;
    [self faceGestureKitUICollectionViewMemento].eyeGestureScrollToNextItem.cutoffTime = eyeScrollingCutoff;
    [self faceGestureKitUICollectionViewMemento].eyeScrollingCutoff = eyeScrollingCutoff;
}

-(UICollectionViewScrollPosition)eyeScrollPosition
{
    return [self faceGestureKitUICollectionViewMemento].eyeScrollPosition;
}

-(void)setEyeScrollPosition:(UICollectionViewScrollPosition)eyeScrollPosition
{
    [self faceGestureKitUICollectionViewMemento].eyeScrollPosition = eyeScrollPosition;
}

-(BOOL)eyeScrollingCircle
{
    return [self faceGestureKitUICollectionViewMemento].eyeScrollingCircle;
}

-(void)setEyeScrollingCircle:(BOOL)eyeScrollingCircle
{
    [self faceGestureKitUICollectionViewMemento].eyeScrollingCircle = eyeScrollingCircle;
}

#pragma mark - Eye selection
-(BOOL)eyeSelectionEnabled
{
    return [self faceGestureKitUICollectionViewMemento].eyeSelectionEnabled;
}

-(void)setEyeSelectionEnabled:(BOOL)eyeSelectionEnabled
{
    if (![self eyeSelectionEnabled] && eyeSelectionEnabled) {
        [self faceGestureKitUICollectionViewMemento].eyeGestureSendDidSelectToCurrentlySelectedItem = [[UIFaceGestureBothEyesDidWink alloc] initWithTarget:self action:@selector(eyeGestureSendDidSelectToCurrentlySelectedRowHandler)];
        [self addFaceGesture:[self faceGestureKitUICollectionViewMemento].eyeGestureSendDidSelectToCurrentlySelectedItem];
    } else if ([self eyeSelectionEnabled] && !eyeSelectionEnabled) {
        [self removeFaceGesture:[self faceGestureKitUICollectionViewMemento].eyeGestureSendDidSelectToCurrentlySelectedItem];
        [self faceGestureKitUICollectionViewMemento].eyeGestureSendDidSelectToCurrentlySelectedItem = nil;
    }
    [self faceGestureKitUICollectionViewMemento].eyeSelectionEnabled = eyeSelectionEnabled;
}

-(void)eyeGestureSendDidSelectToCurrentlySelectedRowHandler
{
    if ([self delegate]) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[self faceGestureKitUICollectionViewMemento].eyeScrolledItemIndex inSection:[self faceGestureKitUICollectionViewMemento].eyeScrolledSection];
        if ([[self delegate] respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)])
        {
            [[self delegate] collectionView:self didSelectItemAtIndexPath:indexPath];
        }
    }
}

-(NSIndexPath*)eyeSelectedIndexPath
{
    return [NSIndexPath indexPathForRow:[self faceGestureKitUICollectionViewMemento].eyeScrolledItemIndex inSection:[self faceGestureKitUICollectionViewMemento].eyeScrolledSection];
}

@end
