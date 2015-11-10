//
//  UITableView+UIFaceGestureKit.h
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 12/08/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (UIFaceGestureKit)
@property (nonatomic) BOOL faceInteractionEnabled;

-(NSIndexPath*)eyeSelectedIndexPath;

// scrolling
@property (nonatomic) BOOL eyeScrollingEnabled;
@property (nonatomic) NSTimeInterval eyeScrollingDelay;
@property (nonatomic) NSTimeInterval eyeScrollingCutoff;
@property (nonatomic) BOOL eyeScrollingCircle;
@property (nonatomic) UITableViewScrollPosition eyeScrollPosition;

// selection
@property (nonatomic) BOOL eyeSelectionEnabled;

@end
