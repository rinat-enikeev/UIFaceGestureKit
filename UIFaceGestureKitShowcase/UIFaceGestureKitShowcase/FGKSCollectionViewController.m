//
//  SecondViewController.m
//  UIFaceGestureKitShowcase
//
//  Created by Rinat Enikeev on 12/08/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import "FGKSCollectionViewController.h"
#import "FGKSSimpleCollectionViewCell.h"
#import "UIFaceGestureKit/UIFaceGestureKit.h"

@interface FGKSCollectionViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *topCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *bottomCollectionView;
@property (strong, nonatomic) NSArray* collectionViewData;
@end

@implementation FGKSCollectionViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionViewData = @[@[@1, @2, @3, @4], @[@5, @6, @7, @8]];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _topCollectionView.faceInteractionEnabled = YES;
    _topCollectionView.eyeScrollingEnabled = YES;
    _topCollectionView.eyeScrollingCircle = YES;
    _topCollectionView.eyeScrollingDelay = 0.3;
    _topCollectionView.eyeSelectionEnabled = YES;
    
    _bottomCollectionView.faceInteractionEnabled = YES;
    _bottomCollectionView.eyeScrollingEnabled = YES;
    _bottomCollectionView.eyeScrollingDelay = 0.6;
    _bottomCollectionView.eyeSelectionEnabled = YES;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _topCollectionView.faceInteractionEnabled = NO;
    _bottomCollectionView.faceInteractionEnabled = NO;
}

#pragma mark - UICollectionViewDatasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_collectionViewData[section] count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"FGKSSimpleCollectionViewCell";
    FGKSSimpleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", _collectionViewData[indexPath.section][indexPath.row]];
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [_collectionViewData count];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(20, 20, 20, 20);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@", ((FGKSSimpleCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath]).textLabel.text);
}

@end
