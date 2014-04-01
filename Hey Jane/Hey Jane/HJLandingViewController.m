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

#define MESSAGE_BUBBLE_HEIGHT_FROM_BOTTOM 50

@interface HJLandingViewController ()
@end

@implementation HJLandingViewController
{
    NSMutableArray *loadedMessages;
    HJNewMessageBubble *newMessageBubbleView;
}
bool isShowingNewMessage = NO;
bool isShowingSettings = NO;

CLLocationManager *locationManager;
bool didReceiveFirstLocation = NO;
HJSettingsPanel *settingsPanel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    loadedMessages = [[NSMutableArray alloc] init];
    [self.mainMapView setDelegate:self];
    [self.mainMapView setShowsPointsOfInterest:NO];
    [self.mainMapView setShowsBuildings:NO];
    [self.mainMapView setShowsUserLocation:YES];
    [self.mainMapView setClusteringEnabled:YES];
    [self.mainMapView setClusteringMethod:OCClusteringMethodBubble];
    
    
    self->newMessageBubbleView = [[[NSBundle mainBundle] loadNibNamed:@"HJNewMessageBubble" owner:self options:nil] objectAtIndex:0];
    
    CGRect newBubbleFrame = self->newMessageBubbleView.layer.frame;
    newBubbleFrame.origin.y = self.view.layer.frame.size.height - MESSAGE_BUBBLE_HEIGHT_FROM_BOTTOM;
    newBubbleFrame.size.height =  self.view.layer.frame.size.height - 216;
    self->newMessageBubbleView.layer.frame = newBubbleFrame;
    
    [self.view addSubview:self->newMessageBubbleView];
    [self->newMessageBubbleView setDelegate:self];
    [self->newMessageBubbleView.messageTextView setUserInteractionEnabled:NO];
    
    UITapGestureRecognizer *settingsButtonTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(didTouchSettingsImage:)];
    
    [self.settingsButtonView addGestureRecognizer:settingsButtonTap];
    
    UITapGestureRecognizer *messageBackgroundTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(didTouchMessageViewBackground:)];
    
    [self.messageBubbleBackgroundImage addGestureRecognizer:messageBackgroundTap];
    
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
//    [self.messageTextView setUserInteractionEnabled:NO];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect newBubbleFrame = self->newMessageBubbleView.layer.frame;
        newBubbleFrame.origin.y = self.view.layer.frame.size.height - 60;
        self->newMessageBubbleView.layer.frame = newBubbleFrame;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            CGRect newBubbleFrame = self->newMessageBubbleView.layer.frame;
            newBubbleFrame.origin.y = self.view.layer.frame.size.height - MESSAGE_BUBBLE_HEIGHT_FROM_BOTTOM;
            self->newMessageBubbleView.layer.frame = newBubbleFrame;
            
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
    [self.mainMapView removeOverlays:self.mainMapView.overlays];
    
    [[HJMessageManager sharedInstance] getMessagesInBackgroundWithin:[self getMapDisplaySizeMeters] nearLocation:self.mainMapView.centerCoordinate withCompletionBlock:^(bool succeeded, NSArray *messages) {
        
        NSMutableArray *newMessages = [[NSMutableArray alloc] init];
        // Determine which (if any) messages are new
        for (PFObject *message in messages) {
            bool didFindMatch = NO;
            
            for (PFObject *oldMessage in loadedMessages) {
                if ([message.objectId isEqualToString:oldMessage.objectId])
                {
                    didFindMatch = YES;
                    break;
                }
            }
            
            if (didFindMatch)
                continue;
            
            [newMessages addObject:message];
            [loadedMessages addObject:message];
        }
        
        for (PFObject *message in newMessages) {
            
            PFGeoPoint *point = [message valueForKey:@"location"];
            
            HJMessageBubbleView *messageView = [[[NSBundle mainBundle] loadNibNamed:@"HJMessageBubbleView"
                                                                              owner:self
                                                                            options:nil] objectAtIndex:0];
            
            
            [messageView setData:message];
            messageView.coordinate = CLLocationCoordinate2DMake(point.latitude, point.longitude);
            
            [self.mainMapView addAnnotation:messageView];
        }
        
    }];
    
    [self.mainMapView doClustering];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[OCAnnotation class]]) {
        static NSString * const identifier = @"HJMessageBubbleViewAnnotation";
        
        OCAnnotation *cluster = (OCAnnotation *) annotation;
        
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
        
        [annotationView setIsGroupWith:[NSNumber numberWithLong:cluster.annotationsInCluster.count]];
        [annotationView setCoordinate:annotation.coordinate];
        
        return annotationView;
    }
    else if ([annotation isKindOfClass:[HJMessageBubbleView class]])
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
        self->newMessageBubbleView.alpha = 1;
    } completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) animateInNewMessageView
{
    self.messageViewBackgroundButton.hidden = NO;
    [UIView animateWithDuration:0.4 animations:^{
        [self->newMessageBubbleView.titleTextView setAlpha:0];
        CGRect newBubbleFrame = self->newMessageBubbleView.layer.frame;
        newBubbleFrame.origin.y = 20;
        self->newMessageBubbleView.layer.frame = newBubbleFrame;
        self.messageViewBackgroundButton.alpha = 1;
        [self->newMessageBubbleView.messageTextView setAlpha:1];
    } completion:^(BOOL finished) {
        [self->newMessageBubbleView.messageTextView setUserInteractionEnabled:YES];
        [self->newMessageBubbleView.messageTextView setText:@""];
        [self->newMessageBubbleView.messageTextView setTextAlignment:NSTextAlignmentLeft];
        [self->newMessageBubbleView.messageTextView becomeFirstResponder];
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

- (void) animateOutNewMessageView
{
    [self->newMessageBubbleView.messageTextView setUserInteractionEnabled:NO];
    [self->newMessageBubbleView.messageTextView resignFirstResponder];
    [UIView animateWithDuration:0.4 animations:^{
        CGRect newBubbleFrame = self->newMessageBubbleView.layer.frame;
        newBubbleFrame.origin.y = self.view.layer.frame.size.height - MESSAGE_BUBBLE_HEIGHT_FROM_BOTTOM;
        self->newMessageBubbleView.layer.frame = newBubbleFrame;
        [self->newMessageBubbleView.titleTextView setAlpha:1];
        [self->newMessageBubbleView.messageTextView setAlpha:0];
        self.messageViewBackgroundButton.alpha = 0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.messageViewBackgroundButton.hidden = YES;
        [self->newMessageBubbleView.messageTextView setText:@""];
        [self->newMessageBubbleView.messageTextView setUserInteractionEnabled:NO];
    }];
    
    isShowingNewMessage = !isShowingNewMessage;
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
        [self bounceTextView];
    }
}

// HJNewMessageBubbleDelegate methods
- (void) didTapView
{
    [self toggleMessageView];
}

- (void) didFinishWithMessage:(NSString *) message
{
    [self toggleMessageView];
    
    if(![message isEqualToString:@""])
    {
        [[HJMessageManager sharedInstance] saveInBackgroundMessage:message withLocation:locationManager.location withCompletionBlock:^(bool succeeded) {
        [self loadAndDisplayMessages];
        }];
    }
    
}

@end
