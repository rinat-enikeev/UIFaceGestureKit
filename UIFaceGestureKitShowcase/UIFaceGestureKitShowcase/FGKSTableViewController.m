//
//  FirstViewController.m
//  UIFaceGestureKitShowcase
//
//  Created by Rinat Enikeev on 12/08/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import "FGKSTableViewController.h"
#import "UIFaceGestureKit/UIFaceGestureKit.h"

@interface FGKSTableViewController ()
@property (strong, nonatomic) NSArray* tableDataSource;
@end

@implementation FGKSTableViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    // two sections in order to show that scrolling bypasses the sections
    self.tableDataSource = @[@[@"Show you face to front cam", @"Close right eye to scroll", @"Selection scrolls down"], @[@"Close left eye only to scroll up", @"Close both eyes for a 1 second", @"Long time! 1 second is long enough", @"In order to select cell"]];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // So simple
    self.tableView.faceInteractionEnabled = YES;
    self.tableView.eyeScrollingEnabled = YES;
    self.tableView.eyeSelectionEnabled = YES;
    self.tableView.eyeScrollingCircle = YES;
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.tableView.faceInteractionEnabled = NO;
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_tableDataSource count];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    view.backgroundColor = [UIColor redColor];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_tableDataSource[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"UiTableViewFaceGestureKitShowcaseCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath: indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", _tableDataSource[indexPath.section][indexPath.row]];
    return cell;
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[[UIAlertView alloc] initWithTitle:nil message:[[[tableView cellForRowAtIndexPath:indexPath] textLabel] text] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil] show];
}

@end
