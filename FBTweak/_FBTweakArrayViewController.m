/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "_FBTweakArrayViewController.h"
#import "FBTweak.h"

@interface _FBTweakArrayViewController ()
#ifndef TARGET_OS_MAC
<UITableViewDataSource, UITableViewDelegate>
#endif

@end

@implementation _FBTweakArrayViewController {
  UITableView *_tableView;
}

- (instancetype)initWithTweak:(FBTweak *)tweak
{
  NSParameterAssert(tweak != nil);
  NSParameterAssert([tweak.possibleValues isKindOfClass:[NSArray class]]);

  if ((self = [super init])) {
    _tweak = tweak;
#ifndef TARGET_OS_MAC
    self.title = _tweak.name;
#endif
  }

  return self;
}

- (void)viewDidLoad
{
#ifndef TARGET_OS_MAC
  [super viewDidLoad];

  _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
  _tableView.delegate = self;
  _tableView.dataSource = self;
  _tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
  [self.view addSubview:_tableView];
#endif
}

#ifndef TARGET_OS_MAC
- (void)dealloc
{
  _tableView.delegate = nil;
  _tableView.dataSource = nil;
}
#endif

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.tweak.possibleValues count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#ifdef TARGET_OS_MAC
  return nil;
#else
  static NSString *_FBTweakDictionaryViewControllerCellIdentifier = @"_FBTweakDictionaryViewControllerCellIdentifier";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_FBTweakDictionaryViewControllerCellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_FBTweakDictionaryViewControllerCellIdentifier];
  }

  FBTweakValue rowValue = self.tweak.possibleValues[indexPath.row];
  NSString *stringValue = [rowValue description];
  cell.textLabel.text = stringValue;

  cell.accessoryType = UITableViewCellAccessoryNone;
  FBTweakValue selectedValue = (self.tweak.currentValue ?: self.tweak.defaultValue);
  if ([selectedValue isEqual:rowValue]) {
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
  }

  return cell;
#endif
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
#ifndef TARGET_OS_MAC
  NSString *value = self.tweak.possibleValues[indexPath.row];
  self.tweak.currentValue = value;
  [self.navigationController popViewControllerAnimated:YES];
#endif
}

@end
