//
//  HJSettingsPanel.h
//  Hey Jane
//
//  Created by Ryan Brink on 2014-03-14.
//  Copyright (c) 2014 HeyJane. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HJSettingsPanelDelegate <NSObject>

- (void) didPressBackground;

@end

@interface HJSettingsPanel : UIView
@property (weak, nonatomic) IBOutlet UITextField *usersNameField;

- (void) setDelegate:(id<HJSettingsPanelDelegate>) delegate;
@end
