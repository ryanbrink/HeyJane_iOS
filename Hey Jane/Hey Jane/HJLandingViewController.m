//
//  HJLandingViewController.m
//  Hey Jane
//
//  Created by Ryan Brink on 2014-03-13.
//  Copyright (c) 2014 HeyJane. All rights reserved.
//

#import "HJLandingViewController.h"

@interface HJLandingViewController ()

@end

@implementation HJLandingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.mainMapView setDelegate:self];
}

- (void) viewDidAppear:(BOOL)animated
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

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered 
{
    if (mapView.alpha == 0)
    {
        [UIView beginAnimations:@"Fade" context:nil];
        [UIView setAnimationDuration:1];
        mapView.alpha = 1;
        [UIView commitAnimations];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
