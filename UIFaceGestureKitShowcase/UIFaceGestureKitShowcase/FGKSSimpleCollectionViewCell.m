//
//  FGKSSimpleCollectionViewCell.m
//  UIFaceGestureKitShowcase
//
//  Created by Rinat Enikeev on 13/08/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import "FGKSSimpleCollectionViewCell.h"

@implementation FGKSSimpleCollectionViewCell

-(void)setSelected:(BOOL)selected
{
    if (selected) {
        self.backgroundColor = [UIColor redColor];
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
    [super setSelected:selected];
}

@end
