//
//  HJLandingViewController.h
//  Hey Jane
//
//  Created by Ryan Brink on 2014-03-13.
//  Copyright (c) 2014 HeyJane. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "HJMessageManager.h"
#import "HJSettingsPanel.h"

@interface HJLandingViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UITextViewDelegate, HJSettingsPanelDelegate>
@property (weak, nonatomic) IBOutlet UIButton *messageViewBackgroundButton;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet MKMapView *mainMapView;
@property (weak, nonatomic) IBOutlet UIImageView *settingsButtonView;

@property (weak, nonatomic) IBOutlet UIView *messagePostView;
@property (weak, nonatomic) IBOutlet UIImageView *messageBubbleBackgroundImage;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageViewHorizontalConstraint;
@property (weak, nonatomic) IBOutlet UITextView *sendMessageView;

@end
