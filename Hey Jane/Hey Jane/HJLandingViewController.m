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

@interface HJLandingViewController ()
@end

@implementation HJLandingViewController
bool isShowingNewMessage = NO;
CLLocationManager *locationManager;
bool didReceiveFirstLocation = NO;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.mainMapView setDelegate:self];
    [self.mainMapView setShowsPointsOfInterest:NO];
    [self.mainMapView setShowsBuildings:NO];
    [self.mainMapView setShowsUserLocation:NO];
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(didTouchMessageView:)];
    [self.messagePostView addGestureRecognizer:singleFingerTap];
    
    UITapGestureRecognizer *messageBackgroundTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(didTouchMessageViewBackground:)];
    
    [self.messageBubbleBackgroundImage addGestureRecognizer:messageBackgroundTap];
    
    [self.messageTextView setDelegate:self];
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
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.messageViewHorizontalConstraint.constant = 80;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.messageViewHorizontalConstraint.constant = 30;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self.messageTextView setText:@""];
            [self.messageTextView setTextAlignment:NSTextAlignmentLeft];
        }];
    }];
}
- (IBAction)didTouchMessageViewBackground:(id)sender {
    [self toggleMessageView];
}

- (void) loadAndDisplayMessages
{
    [[HJMessageManager sharedInstance] getMessagesInBackgroundNearLocation:locationManager.location withCompletionBlock:^(bool succeeded, NSArray *messages) {
        for (PFObject *message in messages) {
            
            NSString * messageString = [message valueForKey:@"message"];
            PFGeoPoint *point = [message valueForKey:@"location"];
            
            HJMessageBubbleView *messageView = [[[NSBundle mainBundle] loadNibNamed:@"HJMessageBubbleView"
                                                                              owner:self
                                                                            options:nil] objectAtIndex:0];
            
            
            [messageView setMessage:messageString];
            messageView.coordinate =CLLocationCoordinate2DMake(point.latitude, point.longitude);
            
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
        
        [annotationView setMessage:bubbleView.messageTextView.text];
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
        self.messageViewHorizontalConstraint.constant = (self.messagePostView.frame.size.height + 216);
        self.messageViewBackgroundButton.alpha = 1;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.messageTextView setText:@""];
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
    [self.messageTextView resignFirstResponder];
    [UIView animateWithDuration:0.4 animations:^{
        self.messageViewHorizontalConstraint.constant = 30;
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

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation

{
    [self loadAndDisplayMessages];
    [self.mainMapView setRegion:MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 200, 200) animated:didReceiveFirstLocation];
    
    didReceiveFirstLocation = YES;
}

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered
{
    if (mapView.alpha == 0 && didReceiveFirstLocation)
    {
        [self fadeInMap];
    }
}

@end
