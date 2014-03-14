//
//  HJLandingViewController.m
//  Hey Jane
//
//  Created by Ryan Brink on 2014-03-13.
//  Copyright (c) 2014 HeyJane. All rights reserved.
//

#import "HJLandingViewController.h"
#import "HJMessageBubbleView.h"
#import <Parse/Parse.h>
#import "HJSettingsPanel.h"
#import  "MKMapView+AttributionView.h"

@interface HJLandingViewController ()
@end

@implementation HJLandingViewController
{

}
bool isShowingNewMessage = NO;
bool isShowingSettings = NO;

CLLocationManager *locationManager;
bool didReceiveFirstLocation = NO;
HJSettingsPanel *settingsPanel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.mainMapView setDelegate:self];
    [self.mainMapView setShowsPointsOfInterest:NO];
    [self.mainMapView setShowsBuildings:NO];
    [self.mainMapView setShowsUserLocation:YES];
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(didTouchMessageView:)];
    [self.messagePostView addGestureRecognizer:singleFingerTap];
    
    UITapGestureRecognizer *messageBackgroundTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(didTouchMessageViewBackground:)];
    
    [self.messageBubbleBackgroundImage addGestureRecognizer:messageBackgroundTap];
    
    UITapGestureRecognizer *settingsButtonTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(didTouchSettingsImage:)];
    
    [self.settingsButtonView addGestureRecognizer:settingsButtonTap];
    
    [self.messageTextView setDelegate:self];
    
    settingsPanel =  [[[NSBundle mainBundle] loadNibNamed:@"HJSettingsPanel"
                                                                                      owner:self
                                                                                    options:nil] objectAtIndex:0];
    CGRect frame = settingsPanel.layer.frame;
    frame.origin.x = self.view.layer.frame.size.width;
    settingsPanel.layer.frame = frame;
    [settingsPanel setDelegate:self];
    [self.view addSubview:settingsPanel];
    
    [self.mainMapView.attributionView setHidden:YES];
}

- (void) viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        // Tell the user to enable location services in settings
        
        // Dissmiss the view
    } else
    {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;;
        [locationManager startUpdatingLocation];
    }

}

- (void) animateOutLogo
{
    CGAffineTransform transform = CGAffineTransformMakeTranslation(600,-600);
    transform = CGAffineTransformRotate(transform, 1.5);
    [UIView beginAnimations:@"MoveAndRotateAnimation" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.75];
    
    self.logoImageView.transform = transform;
    CGPoint center         = CGPointMake(-200, self.logoImageView.center.y);
    self.logoImageView.center       = center;
    [UIView commitAnimations];

}

- (void) bounceTextView
{
    [self.messageTextView setUserInteractionEnabled:NO];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.messageViewHorizontalConstraint.constant = 100;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.messageViewHorizontalConstraint.constant = 50;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
        }];
    }];
}
- (IBAction)didTouchMessageViewBackground:(id)sender {
    [self toggleMessageView];
}

- (void) toggleSettingsView
{
    if (isShowingSettings)
    {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = settingsPanel.layer.frame;
            frame.origin.x = self.view.layer.frame.size.width;
            settingsPanel.layer.frame = frame;
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = settingsPanel.layer.frame;
            frame.origin.x = 0;
            settingsPanel.layer.frame = frame;
        }];
    }
    
    isShowingSettings = !isShowingSettings;
}

- (void) didPressBackground
{
    [self toggleSettingsView];
}

- (IBAction)didTouchSettingsImage:(id)sender {
    [self toggleSettingsView];
}

- (void) loadAndDisplayMessages
{
    [[HJMessageManager sharedInstance] getMessagesInBackgroundWithin:[self getMapDisplaySizeMeters] nearLocation:self.mainMapView.centerCoordinate withCompletionBlock:^(bool succeeded, NSArray *messages) {
        for (PFObject *message in messages) {
            
            PFGeoPoint *point = [message valueForKey:@"location"];
            
            HJMessageBubbleView *messageView = [[[NSBundle mainBundle] loadNibNamed:@"HJMessageBubbleView"
                                                                              owner:self
                                                                            options:nil] objectAtIndex:0];
            
            
            [messageView setData:message];
            messageView.coordinate = CLLocationCoordinate2DMake(point.latitude, point.longitude);
            
            [self.mainMapView addAnnotation:messageView];
        }
        
    }];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[HJMessageBubbleView class]])
    {
        HJMessageBubbleView *bubbleView = (HJMessageBubbleView *) annotation;
        static NSString * const identifier = @"HJMessageBubbleViewAnnotation";
        
        HJMessageBubbleView* annotationView = (HJMessageBubbleView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (annotationView)
        {
            annotationView.annotation = annotation;
        }
        else
        {
            
            annotationView = [[[NSBundle mainBundle] loadNibNamed:@"HJMessageBubbleView"
                                                                              owner:self
                                                                            options:nil] objectAtIndex:0];
        }
        
        [annotationView setData:bubbleView.objectData];
        [annotationView setCoordinate:bubbleView.coordinate];

        return annotationView;
    }
    else
    {
        return nil;
    }
}


- (void) fadeInMap
{
    [UIView animateWithDuration:0.75 animations:^{
        self.mainMapView.alpha = 1;
        self.messagePostView.alpha = 1;
    } completion:^(BOOL finished) {
        [self bounceTextView];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) animateInNewMessageView
{
    [self.view layoutIfNeeded];
    self.messageViewBackgroundButton.hidden = NO;
    [UIView animateWithDuration:0.4 animations:^{
        [self.sendMessageView setAlpha:0];
        self.messageViewHorizontalConstraint.constant = (self.messagePostView.frame.size.height + 216);
        self.messageViewBackgroundButton.alpha = 1;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.messageTextView setUserInteractionEnabled:YES];
        [self.messageTextView setText:@""];
        [self.messageTextView setTextAlignment:NSTextAlignmentLeft];
        [self.messageTextView becomeFirstResponder];
    }];
    
    isShowingNewMessage = !isShowingNewMessage;
}

- (void) toggleMessageView
{
    if (isShowingNewMessage)
    {
        [self animateOutNewMessageView];
    }
    else
    {
        [self animateInNewMessageView];
    }
}
- (void)didTouchMessageView:(UITapGestureRecognizer *)recognizer
{
    [self toggleMessageView];
}

- (void) animateOutNewMessageView
{
    [self.messageTextView setUserInteractionEnabled:NO];
    [self.messageTextView resignFirstResponder];
    [UIView animateWithDuration:0.4 animations:^{
        [self.sendMessageView setAlpha:1];
        self.messageViewHorizontalConstraint.constant = 50;
        self.messageViewBackgroundButton.alpha = 0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.messageViewBackgroundButton.hidden = YES;
        [self.messageTextView setText:@""];
    }];
    
    isShowingNewMessage = !isShowingNewMessage;
}

- (IBAction)didPressGo:(id)sender {
    [[HJMessageManager sharedInstance] saveInBackgroundMessage:self.messageTextView.text withLocation:locationManager.location withCompletionBlock:^(bool succeeded) {
        [self loadAndDisplayMessages];
    }];
    
    [self animateOutNewMessageView];
}

#define MAX_LENGTH 130 // Whatever your limit is
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSUInteger newLength = (textView.text.length - range.length) + text.length;
    if(newLength <= MAX_LENGTH)
    {
        return YES;
    } else {
        NSUInteger emptySpace = MAX_LENGTH - (textView.text.length - range.length);
        textView.text = [[[textView.text substringToIndex:range.location]
                          stringByAppendingString:[text substringToIndex:emptySpace]]
                         stringByAppendingString:[textView.text substringFromIndex:(range.location + range.length)]];
        return NO;
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusDenied:
            break;
        case kCLAuthorizationStatusRestricted:
            break;
        default:
            [self animateOutLogo];
            break;
    }
}

- (int) getMapDisplaySizeMeters
{
    MKMapRect mRect = self.mainMapView.visibleMapRect;
    MKMapPoint eastMapPoint = MKMapPointMake(MKMapRectGetMinX(mRect), MKMapRectGetMidY(mRect));
    MKMapPoint westMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMidY(mRect));
    
    return MKMetersBetweenMapPoints(eastMapPoint, westMapPoint)/1000;
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation

{
    if (!didReceiveFirstLocation)
    {
        [[HJMessageManager sharedInstance] getApproximateRadiusInKilometersToRevealTenMessagesAroundCoordinate:newLocation.coordinate withCompletionBlock:^(bool succeeded, NSNumber *kilometers) {
           if (succeeded)
           {
               [self loadAndDisplayMessages];

               NSLog(@"Setting initial zoom to %dKm.", [kilometers intValue]);
               
               [self.mainMapView setRegion:MKCoordinateRegionMakeWithDistance(newLocation.coordinate, [kilometers integerValue]*1000, [kilometers integerValue]*1000) animated:didReceiveFirstLocation];
               
               
           }
        }];
        
    }
    
    didReceiveFirstLocation = YES;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self loadAndDisplayMessages];
}

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered
{
    if (mapView.alpha == 0 && didReceiveFirstLocation)
    {
        [self fadeInMap];
    }
}

@end
