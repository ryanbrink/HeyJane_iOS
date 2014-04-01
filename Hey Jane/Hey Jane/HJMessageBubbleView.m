//
//  HJMessageBubbleView.m
//  Hey Jane
//
//  Created by Ryan Brink on 2014-03-13.
//  Copyright (c) 2014 HeyJane. All rights reserved.
//

#import "HJMessageBubbleView.h"


@implementation HJMessageBubbleView
@synthesize objectData;


- (IBAction) upVote:(id)sender
{
    [[self objectData] incrementKey:@"votes"];
    [[self objectData] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!succeeded)
        {
            NSLog(@"%@", error);
        }
    }];
}

- (IBAction) downVote:(id)sender
{
    [[self objectData] incrementKey:@"votes" byAmount:[NSNumber numberWithInt:-2]];
    [[self objectData] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!succeeded)
        {
            NSLog(@"%@", error);
        }
    }];
}

- (void) setIsGroupWith:(NSNumber *) numberOfMessages
{
    [self.messageTextView setText:[NSString stringWithFormat:@"%ld messages", (long)[numberOfMessages integerValue]]];
    [self.messageTextView setFont:[UIFont fontWithName:@"Gill Sans" size:15.0f]];
    
    CGRect rect = [self.messageTextView.layoutManager usedRectForTextContainer:self.messageTextView.textContainer];
    
    self.textBackgroundHeightConstraint.constant = rect.size.height;
    self.usersNameXConstraint.constant = -(self.messageTextView.layer.frame.size.height - rect.size.height);
    
    self.subViewVerticalSpace.constant += (self.messageTextView.layer.frame.size.height-20 - rect.size.height);
 
    [self.downVoteButton setHidden:YES];
    [self.upVoteButton setHidden:YES];
    [self.usersNameLabel setText:@""];
}

- (void) setData:(PFObject *) data
{
    [self.downVoteButton setHidden:NO];
    [self.upVoteButton setHidden:NO];
    [self setObjectData:data];
    [self.messageTextView setText:[data valueForKey:@"message"]];
    [self.messageTextView setFont:[UIFont fontWithName:@"Gill Sans" size:15.0f]];

    CGRect rect = [self.messageTextView.layoutManager usedRectForTextContainer:self.messageTextView.textContainer];
    
    self.textBackgroundHeightConstraint.constant = rect.size.height;
    self.usersNameXConstraint.constant = -(self.messageTextView.layer.frame.size.height - rect.size.height);
    
    self.subViewVerticalSpace.constant += (self.messageTextView.layer.frame.size.height-20 - rect.size.height);
    
    [self.usersNameLabel setText:[data valueForKey:@"usersName"]];
    
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
