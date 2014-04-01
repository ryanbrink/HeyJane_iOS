//
//  HJMessageBubbleView.h
//  Hey Jane
//
//  Created by Ryan Brink on 2014-03-13.
//  Copyright (c) 2014 HeyJane. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

@interface HJMessageBubbleView : MKAnnotationView <MKAnnotation>
{
    CLLocationCoordinate2D coordinate;
}
@property (weak, nonatomic) IBOutlet UIButton *upVoteButton;
@property (weak, nonatomic) IBOutlet UIButton *downVoteButton;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (strong, nonatomic) PFObject *objectData;

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textBackgroundHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *usersNameXConstraint;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UILabel *usersNameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subViewHorizontalSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subViewVerticalSpace;

- (void) setIsGroupWith:(NSNumber *) numberOfMessages;
- (void) setData:(PFObject *) data;
@end
