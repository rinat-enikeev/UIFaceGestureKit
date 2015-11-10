//
//  UICollectionView+UIFaceGestureKit.h
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 12/08/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICollectionView (UIFaceGestureKit)

@property (nonatomic) BOOL faceInteractionEnabled;

@property (nonatomic) BOOL eyeScrollingEnabled;
@property (nonatomic) BOOL eyeScrollingCircle;
@property (nonatomic) NSTimeInterval eyeScrollingDelay;
@property (nonatomic) NSTimeInterval eyeScrollingCutoff;
@property (nonatomic) UICollectionViewScrollPosition eyeScrollPosition;

@property (nonatomic) BOOL eyeSelectionEnabled;

-(NSIndexPath*)eyeSelectedIndexPath;

@end
