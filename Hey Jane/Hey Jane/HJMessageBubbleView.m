//
//  HJMessageBubbleView.m
//  Hey Jane
//
//  Created by Ryan Brink on 2014-03-13.
//  Copyright (c) 2014 HeyJane. All rights reserved.
//

#import "HJMessageBubbleView.h"

@implementation HJMessageBubbleView

- (void) awakeFromNib
{
    [super awakeFromNib];
}

- (void) setMessage:(NSString *) message
{
    [self.messageTextView setText:message];
    [self.messageTextView setFont:[UIFont fontWithName:@"Gill Sans" size:15.0f]];
    [self layoutIfNeeded];

    CGRect rect = [self.messageTextView.layoutManager usedRectForTextContainer:self.messageTextView.textContainer];
    
    self.textBackgroundHeightConstraint.constant = rect.size.height;
    
    [self layoutIfNeeded];
}

- (CLLocationCoordinate2D)coordinate
{
    return coordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    coordinate = newCoordinate;
}

@end
