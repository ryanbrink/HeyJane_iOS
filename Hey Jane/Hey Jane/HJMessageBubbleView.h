//
//  HJMessageBubbleView.h
//  Hey Jane
//
//  Created by Ryan Brink on 2014-03-13.
//  Copyright (c) 2014 HeyJane. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface HJMessageBubbleView : MKAnnotationView <MKAnnotation>
{
    CLLocationCoordinate2D coordinate;
}
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textBackgroundHeightConstraint;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;

- (void) setMessage:(NSString *) message;
@end
