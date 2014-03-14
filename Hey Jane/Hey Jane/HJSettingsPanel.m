//
//  HJSettingsPanel.m
//  Hey Jane
//
//  Created by Ryan Brink on 2014-03-14.
//  Copyright (c) 2014 HeyJane. All rights reserved.
//

#import "HJSettingsPanel.h"

@implementation HJSettingsPanel
{
    id<HJSettingsPanelDelegate> myDelegate;
    NSUserDefaults *userDefaults;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.usersNameField.leftView = paddingView;
    self.usersNameField.leftViewMode = UITextFieldViewModeAlways;
    
    [self.usersNameField setTintColor:[UIColor blackColor]];
    userDefaults = [NSUserDefaults standardUserDefaults];
    [self.usersNameField setText:[userDefaults stringForKey:@"usersName"]];
}

- (void) setDelegate:(id<HJSettingsPanelDelegate>) delegate
{
    self->myDelegate = delegate;
}

- (IBAction)onBackgroundTouched:(id)sender {
    
    [self.usersNameField resignFirstResponder];
    [userDefaults setObject:self.usersNameField.text forKey:@"usersName"];
    [userDefaults synchronize];
    [self->myDelegate didPressBackground];
}

@end
