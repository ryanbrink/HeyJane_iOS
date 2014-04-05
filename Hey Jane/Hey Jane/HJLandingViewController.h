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
#import "CCHMapClusterController.h"
#import "CCHMapClusterAnnotation.h"
#import "HJNewMessageBubble.h"
#import "HJMessageBubbleView.h"

@interface HJLandingViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, HJSettingsPanelDelegate, HJNewMessageBubbleDelegate, HJMessageBubbleViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *messageBubbleBackgroundImage;
@property (weak, nonatomic) IBOutlet UIButton *messageViewBackgroundButton;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet MKMapView *mainMapView;
@property (weak, nonatomic) IBOutlet UIImageView *settingsButtonView;


@end
