//
//  UITableView+UIFaceGestureKit.m
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 12/08/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import "UITableView+UIFaceGestureKit.h"
#import "UIFaceGestureKitEyeGestures.h"
#import <objc/runtime.h>

@interface UIFaceGestureKitUITableViewMemento : NSObject
@property (nonatomic, strong) NSMutableSet* faceGestures;
@property (nonatomic) BOOL faceInteractionEnabled;

@property (nonatomic) BOOL eyeScrollingEnabled;
@property (nonatomic) NSTimeInterval eyeScrollingDelay;
@property (nonatomic) NSTimeInterval eyeScrollingCutoff;
@property (nonatomic) BOOL eyeScrollingCircle;
@property (nonatomic) UITableViewScrollPosition eyeScrollPosition;
@property (nonatomic) NSInteger eyeScrolledRow;
@property (nonatomic) NSInteger eyeScrolledSection;
@property (strong, nonatomic) UIFaceGestureLeftEyeIsClosed* eyeGestureScrollToPreviousRow;
@property (strong, nonatomic) UIFaceGestureRightEyeIsClosed* eyeGestureScrollToNextRow;
@property (strong, nonatomic) UIFaceGestureLeftEyeDidWink* eyeGestureWinkScrollToPreviousRow;
@property (strong, nonatomic) UIFaceGestureRightEyeDidWink* eyeGestureWinkScrollToNextRow;

@property (nonatomic) BOOL eyeSelectionEnabled;
@property (strong, nonatomic) UIFaceGestureBothEyesDidWink* eyeGestureSendDidSelectToCurrentlySelectedRow;

@end

@implementation UIFaceGestureKitUITableViewMemento

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

static void *UIFaceGestureKitUITableViewMementoKey;

@implementation UITableView (UIFaceGestureKit)

#pragma mark - Memento properties
- (UIFaceGestureKitUITableViewMemento *)faceGestureKitUITableViewMemento
{
    UIFaceGestureKitUITableViewMemento* faceGestureKitUITableViewMemento = objc_getAssociatedObject(self, UIFaceGestureKitUITableViewMementoKey);
    if (!faceGestureKitUITableViewMemento) {
        faceGestureKitUITableViewMemento = [[UIFaceGestureKitUITableViewMemento alloc] init];
        objc_setAssociatedObject(self, UIFaceGestureKitUITableViewMementoKey, faceGestureKitUITableViewMemento, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return faceGestureKitUITableViewMemento;
}

#pragma mark - FaceInteraction Common
-(BOOL)faceInteractionEnabled
{
    return [self faceGestureKitUITableViewMemento].faceInteractionEnabled;
}

-(void)setFaceInteractionEnabled:(BOOL)faceInteractionEnabled
{
    for (UIFaceGesture* gesture in [[self faceGestureKitUITableViewMemento] faceGestures]) {
        gesture.enabled = faceInteractionEnabled;
    }
    [self faceGestureKitUITableViewMemento].faceInteractionEnabled = faceInteractionEnabled;
}

#pragma mark Eye gestures management
-(void)addFaceGesture:(UIFaceGesture*)eyeGesture
{
    [[[self faceGestureKitUITableViewMemento] faceGestures] addObject:eyeGesture];
    if ([self faceInteractionEnabled]) {
        eyeGesture.enabled = YES;
    }
}

-(void)removeFaceGesture:(UIFaceGesture*)eyeGesture
{
    [[[self faceGestureKitUITableViewMemento] faceGestures] removeObject:eyeGesture];
    eyeGesture.enabled = NO;
}

#pragma mark Eye scrolling
-(BOOL)eyeScrollingEnabled
{
    return [self faceGestureKitUITableViewMemento].eyeScrollingEnabled;
}

-(void)setEyeScrollingEnabled:(BOOL)eyeScrollingEnabled
{
    if (![self eyeScrollingEnabled] && eyeScrollingEnabled) {
        
        [self faceGestureKitUITableViewMemento].eyeGestureScrollToPreviousRow = [[UIFaceGestureLeftEyeIsClosed alloc] initWithTarget:self action:@selector(eyeGestureScrollToPreviousRowHandler) repeatInterval:[self eyeScrollingDelay] cutoffTime:[self eyeScrollingCutoff]];
        [self addFaceGesture:[self faceGestureKitUITableViewMemento].eyeGestureScrollToPreviousRow];
        
        [self faceGestureKitUITableViewMemento].eyeGestureScrollToNextRow = [[UIFaceGestureRightEyeIsClosed alloc] initWithTarget:self action:@selector(eyeGestureScrollToNextRowHandler) repeatInterval:[self eyeScrollingDelay]  cutoffTime:[self eyeScrollingCutoff]];
        [self addFaceGesture:[self faceGestureKitUITableViewMemento].eyeGestureScrollToNextRow];
        
        [self faceGestureKitUITableViewMemento].eyeGestureWinkScrollToPreviousRow = [[UIFaceGestureLeftEyeDidWink alloc] initWithTarget:self action:@selector(eyeGestureScrollToPreviousRowHandler)];
        [self addFaceGesture:[self faceGestureKitUITableViewMemento].eyeGestureWinkScrollToPreviousRow];
        [self faceGestureKitUITableViewMemento].eyeGestureWinkScrollToNextRow = [[UIFaceGestureRightEyeDidWink alloc] initWithTarget:self action:@selector(eyeGestureScrollToNextRowHandler)];
        [self addFaceGesture:[self faceGestureKitUITableViewMemento].eyeGestureWinkScrollToNextRow ];
    } else if ([self eyeScrollingEnabled] && !eyeScrollingEnabled) {
        [self removeFaceGesture:[self faceGestureKitUITableViewMemento].eyeGestureScrollToPreviousRow];
        [self faceGestureKitUITableViewMemento].eyeGestureScrollToPreviousRow = nil;
        [self removeFaceGesture:[self faceGestureKitUITableViewMemento].eyeGestureScrollToNextRow];
        [self faceGestureKitUITableViewMemento].eyeGestureScrollToNextRow = nil;
        [self removeFaceGesture:[self faceGestureKitUITableViewMemento].eyeGestureWinkScrollToPreviousRow];
        [self faceGestureKitUITableViewMemento].eyeGestureWinkScrollToPreviousRow = nil;
        [self removeFaceGesture:[self faceGestureKitUITableViewMemento].eyeGestureWinkScrollToNextRow];
        [self faceGestureKitUITableViewMemento].eyeGestureWinkScrollToNextRow = nil;
    }
    [self faceGestureKitUITableViewMemento].eyeScrollingEnabled = eyeScrollingEnabled;
}

-(NSTimeInterval)eyeScrollingDelay
{
    return [self faceGestureKitUITableViewMemento].eyeScrollingDelay;
}

-(void)setEyeScrollingDelay:(NSTimeInterval)eyeScrollingDelay
{
    [self faceGestureKitUITableViewMemento].eyeGestureScrollToPreviousRow.repeatInterval = eyeScrollingDelay;
    [self faceGestureKitUITableViewMemento].eyeGestureScrollToNextRow.repeatInterval = eyeScrollingDelay;
    [self faceGestureKitUITableViewMemento].eyeScrollingDelay = eyeScrollingDelay;
}

-(NSTimeInterval)eyeScrollingCutoff
{
    return [self faceGestureKitUITableViewMemento].eyeScrollingCutoff;
}

-(void)setEyeScrollingCutoff:(NSTimeInterval)eyeScrollingCutoff
{
    [self faceGestureKitUITableViewMemento].eyeGestureScrollToPreviousRow.cutoffTime = eyeScrollingCutoff;
    [self faceGestureKitUITableViewMemento].eyeGestureScrollToNextRow.cutoffTime = eyeScrollingCutoff;
    [self faceGestureKitUITableViewMemento].eyeScrollingCutoff = eyeScrollingCutoff;
}


-(NSIndexPath*)eyeSelectedIndexPath
{
    return [NSIndexPath indexPathForRow:[self faceGestureKitUITableViewMemento].eyeScrolledRow inSection:[self faceGestureKitUITableViewMemento].eyeScrolledSection];
}

-(void)eyeGestureScrollToPreviousRowHandler
{
    if (([self faceInteractionEnabled])) {
        BOOL currentRowIsFirstInFirstSection = [self faceGestureKitUITableViewMemento].eyeScrolledSection == 0
        && [self faceGestureKitUITableViewMemento].eyeScrolledRow == 0;
        if (![self faceGestureKitUITableViewMemento].eyeScrollingCircle
            && currentRowIsFirstInFirstSection)
        {
            // do not scroll - circle is NO
        } else {
            [self decrementScrolledRow];
            [self eyeScrollingSelectRow:[self faceGestureKitUITableViewMemento].eyeScrolledRow inSection:[self faceGestureKitUITableViewMemento].eyeScrolledSection];
        }
    }
}

-(void)eyeGestureScrollToNextRowHandler
{
    if ([self faceInteractionEnabled]) {
        BOOL currentRowIsLastInLastSection = [self faceGestureKitUITableViewMemento].eyeScrolledSection == [self numberOfSections] - 1
            && [self faceGestureKitUITableViewMemento].eyeScrolledRow == [self numberOfRowsInSection:[self faceGestureKitUITableViewMemento].eyeScrolledSection] - 1;
        
        if (![self faceGestureKitUITableViewMemento].eyeScrollingCircle
            && currentRowIsLastInLastSection) {
            // do not scroll
        } else  {
            [self incremetScrolledRow];
            [self eyeScrollingSelectRow:[self faceGestureKitUITableViewMemento].eyeScrolledRow inSection:[self faceGestureKitUITableViewMemento].eyeScrolledSection];
        }
    }
}

- (void)eyeScrollingSelectRow:(NSInteger)row inSection:(NSInteger)section
{
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:row inSection:section];
    [self selectRowAtIndexPath:indexPath animated:YES scrollPosition:[self faceGestureKitUITableViewMemento].eyeScrollPosition];
}

-(UITableViewScrollPosition)eyeScrollPosition
{
    return [self faceGestureKitUITableViewMemento].eyeScrollPosition;
}

-(void)setEyeScrollPosition:(UITableViewScrollPosition)eyeScrollPosition
{
    [self faceGestureKitUITableViewMemento].eyeScrollPosition = eyeScrollPosition;
}

-(void)incremetScrolledRow
{
    NSInteger numberOfRowsInCurrentSection = [self numberOfRowsInSection:[self faceGestureKitUITableViewMemento].eyeScrolledSection];
    NSInteger numberOfSections = [self numberOfSections];
    NSInteger currentRow = [self faceGestureKitUITableViewMemento].eyeScrolledRow;
    NSInteger currentSection = [self faceGestureKitUITableViewMemento].eyeScrolledSection;
    
    BOOL currentRowIsLastInSection = (currentRow == numberOfRowsInCurrentSection - 1);
    if (currentRowIsLastInSection) {
        if (currentSection < numberOfSections - 1) {
            currentSection++;
            currentRow = 0;
        } else if (currentSection == numberOfSections - 1) {
            currentSection = 0;
            currentRow = 0;
        }
    } else {
        currentRow++;
    }
    
    [self faceGestureKitUITableViewMemento].eyeScrolledRow = currentRow;
    [self faceGestureKitUITableViewMemento].eyeScrolledSection = currentSection;
}

-(void)decrementScrolledRow
{
    NSInteger numberOfSections = [self numberOfSections];
    NSInteger currentRow = [self faceGestureKitUITableViewMemento].eyeScrolledRow;
    NSInteger currentSection = [self faceGestureKitUITableViewMemento].eyeScrolledSection;
    
    BOOL currentRowIsFirstInSection = currentRow == 0;

    if (currentRowIsFirstInSection) {
        if (currentSection == 0) {
            currentSection = numberOfSections - 1;
        } else {
            currentSection--;
        }
        currentRow = [self numberOfRowsInSection:currentSection] - 1;
    } else {
        currentRow--;
    }
    
    [self faceGestureKitUITableViewMemento].eyeScrolledRow = currentRow;
    [self faceGestureKitUITableViewMemento].eyeScrolledSection = currentSection;
}

-(BOOL)eyeScrollingCircle
{
    return [self faceGestureKitUITableViewMemento].eyeScrollingCircle;
}

-(void)setEyeScrollingCircle:(BOOL)eyeScrollingCircle
{
    [self faceGestureKitUITableViewMemento].eyeScrollingCircle = eyeScrollingCircle;
}

#pragma mark - Eye selection
-(BOOL)eyeSelectionEnabled
{
    return [self faceGestureKitUITableViewMemento].eyeSelectionEnabled;
}

-(void)setEyeSelectionEnabled:(BOOL)eyeSelectionEnabled
{
    if (![self eyeSelectionEnabled] && eyeSelectionEnabled) {
        [self faceGestureKitUITableViewMemento].eyeGestureSendDidSelectToCurrentlySelectedRow = [[UIFaceGestureBothEyesDidWink alloc] initWithTarget:self action:@selector(eyeGestureSendDidSelectToCurrentlySelectedRowHandler)];
        [self addFaceGesture:[self faceGestureKitUITableViewMemento].eyeGestureSendDidSelectToCurrentlySelectedRow];
    } else if ([self eyeSelectionEnabled] && !eyeSelectionEnabled) {
        [self removeFaceGesture:[self faceGestureKitUITableViewMemento].eyeGestureSendDidSelectToCurrentlySelectedRow];
        [self faceGestureKitUITableViewMemento].eyeGestureSendDidSelectToCurrentlySelectedRow = nil;
    }
    [self faceGestureKitUITableViewMemento].eyeSelectionEnabled = eyeSelectionEnabled;
}

-(void)eyeGestureSendDidSelectToCurrentlySelectedRowHandler
{
    if ([self delegate]) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[self faceGestureKitUITableViewMemento].eyeScrolledRow inSection:[self faceGestureKitUITableViewMemento].eyeScrolledSection];
        if ([[self delegate] respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)])
        {
            [[self delegate] tableView:self didSelectRowAtIndexPath:indexPath];
        }
    }
}




@end
