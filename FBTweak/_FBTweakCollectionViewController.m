/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBTweakCollection.h"
#import "FBTweakCategory.h"
#import "FBTweak.h"
#import "_FBTweakCollectionViewController.h"
#import "_FBTweakTableViewCell.h"
#import "_FBTweakDictionaryViewController.h"
#import "_FBTweakArrayViewController.h"

@interface _FBTweakCollectionViewController ()
#ifndef TARGET_OS_MAC
<UITableViewDelegate, UITableViewDataSource>
#endif
@end

@implementation _FBTweakCollectionViewController {
  UITableView *_tableView;
  NSArray *_sortedCollections;
}

- (instancetype)initWithTweakCategory:(FBTweakCategory *)category
{
  if ((self = [super init])) {
    _tweakCategory = category;
#ifndef TARGET_OS_MAC
    self.title = _tweakCategory.name;
#endif
    [self _reloadData];
  }
  
  return self;
}

- (void)viewDidLoad
{
#ifndef TARGET_OS_MAC
  [super viewDidLoad];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardFrameChanged:) name:UIKeyboardWillChangeFrameNotification object:nil];
  
  _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
  _tableView.delegate = self;
  _tableView.dataSource = self;
  _tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
  [self.view addSubview:_tableView];
  
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(_done)];
#endif
}

- (void)dealloc
{
#ifndef TARGET_OS_MAC
  _tableView.delegate = nil;
  _tableView.dataSource = nil;
#endif
}

- (void)viewWillAppear:(BOOL)animated
{
#ifndef TARGET_OS_MAC
  [super viewWillAppear:animated];
  
  [_tableView deselectRowAtIndexPath:_tableView.indexPathForSelectedRow animated:animated];
  [self _reloadData];
#endif
}

- (void)_reloadData
{
#ifndef TARGET_OS_MAC
  _sortedCollections = [_tweakCategory.tweakCollections sortedArrayUsingComparator:^(FBTweakCollection *a, FBTweakCollection *b) {
    return [a.name localizedStandardCompare:b.name];
  }];
  [_tableView reloadData];
#endif
}

- (void)_done
{
#ifndef TARGET_OS_MAC
  [_delegate tweakCollectionViewControllerSelectedDone:self];
#endif
}

- (void)_keyboardFrameChanged:(NSNotification *)notification
{
#ifndef TARGET_OS_MAC
  CGRect endFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
  endFrame = [self.view.window convertRect:endFrame fromWindow:nil];
  endFrame = [self.view convertRect:endFrame fromView:self.view.window];
  
  NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
  UIViewAnimationCurve curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];

  __weak typeof(self) weakSelf = self;
  __weak typeof(_tableView) weakTableView = _tableView;
  void (^animations)() = ^{
    UIEdgeInsets contentInset = weakTableView.contentInset;
    contentInset.bottom = (weakSelf.view.bounds.size.height - CGRectGetMinY(endFrame));
    weakTableView.contentInset = contentInset;
    
    UIEdgeInsets scrollIndicatorInsets = weakTableView.scrollIndicatorInsets;
    scrollIndicatorInsets.bottom = (weakSelf.view.bounds.size.height - CGRectGetMinY(endFrame));
    weakTableView.scrollIndicatorInsets = scrollIndicatorInsets;
  };
  
  UIViewAnimationOptions options = (curve << 16) | UIViewAnimationOptionBeginFromCurrentState;
  
  [UIView animateWithDuration:duration delay:0 options:options animations:animations completion:NULL];
#endif
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return _sortedCollections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  FBTweakCollection *collection = _sortedCollections[section];
  return collection.tweaks.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  FBTweakCollection *collection = _sortedCollections[section];
  return collection.name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#ifdef TARGET_OS_MAC
    return nil;
#else
  static NSString *_FBTweakCollectionViewControllerCellIdentifier = @"_FBTweakCollectionViewControllerCellIdentifier";
  _FBTweakTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_FBTweakCollectionViewControllerCellIdentifier];
  if (cell == nil) {
    cell = [[_FBTweakTableViewCell alloc] initWithReuseIdentifier:_FBTweakCollectionViewControllerCellIdentifier];
  }
  
  FBTweakCollection *collection = _sortedCollections[indexPath.section];
  FBTweak *tweak = collection.tweaks[indexPath.row];
  cell.tweak = tweak;
  
  return cell;
#endif
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
#ifndef TARGET_OS_MAC
  FBTweakCollection *collection = _sortedCollections[indexPath.section];
  FBTweak *tweak = collection.tweaks[indexPath.row];
  if ([tweak.possibleValues isKindOfClass:[NSDictionary class]]) {
    _FBTweakDictionaryViewController *vc = [[_FBTweakDictionaryViewController alloc] initWithTweak:tweak];
    [self.navigationController pushViewController:vc animated:YES];
  } else if ([tweak.possibleValues isKindOfClass:[NSArray class]]) {
    _FBTweakArrayViewController *vc = [[_FBTweakArrayViewController alloc] initWithTweak:tweak];
    [self.navigationController pushViewController:vc animated:YES];
  }
#endif
}

@end
