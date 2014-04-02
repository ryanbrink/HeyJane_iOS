//
//  HJMessageBubbleView.m
//  Hey Jane
//
//  Created by Ryan Brink on 2014-03-13.
//  Copyright (c) 2014 HeyJane. All rights reserved.
//

#import "HJMessageBubbleView.h"


@implementation HJMessageBubbleView
{
    NSSet *groupedMessages;
    bool isExpanded;
}
@synthesize objectData;

- (void) awakeFromNib
{
    isExpanded = FALSE;

}
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

- (void) setIsGroupWith:(NSSet *) groupedMessageViews
{
    isExpanded = FALSE;
    
    self->groupedMessages = groupedMessageViews;
    [self.messageTextView setText:[NSString stringWithFormat:@"%lu messages", (unsigned long)groupedMessageViews.count]];
    [self.messageTextView setFont:[UIFont fontWithName:@"Gill Sans" size:15.0f]];
    
    [self resizeToFitText];
    
    [self.downVoteButton setHidden:YES];
    [self.upVoteButton setHidden:YES];
    [self.usersNameLabel setText:@""];
}

- (void) setData:(PFObject *) data
{
    isExpanded = FALSE;
    self->groupedMessages = nil;
    [self.downVoteButton setHidden:NO];
    [self.upVoteButton setHidden:NO];
    [self setObjectData:data];
    
    // Make sure there is plenty of space for the new message
    int resize = 300 - (self.textBackgroundImageView.frame.size.height);
    self.containerHeight.constant += resize;
    self.subViewVerticalSpace.constant -= resize;
    
    [self.messageTextView setText:[data valueForKey:@"message"]];
    [self.messageTextView setFont:[UIFont fontWithName:@"Gill Sans" size:15.0f]];
    [self layoutIfNeeded];

    [self resizeToFitText];
    
    [self.usersNameLabel setText:[data valueForKey:@"usersName"]];
}

- (void) resizeToFitText
{
    CGRect rect = [self.messageTextView.layoutManager usedRectForTextContainer:self.messageTextView.textContainer];
    
    int resize = rect.size.height + 20 - (self.textBackgroundImageView.frame.size.height);
    
    self.containerHeight.constant += resize;
    self.subViewVerticalSpace.constant -= resize;

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
- (IBAction)didPressBackgroundButton:(id)sender {
    if (groupedMessages == nil)
        return;
    
    if (isExpanded)
    {
        [self contract];
    } else {
        [self expand];
    }
    
    isExpanded = !isExpanded;
}

- (void) expand
{
    [UIView animateWithDuration:0.3 animations:^{
        self.containerHeight.constant += 200;
        self.subViewVerticalSpace.constant -= 200;
        
        [self layoutIfNeeded];
    }];
}
- (void) contract
{
    [UIView animateWithDuration:0.3 animations:^{
        self.containerHeight.constant += -200;
        self.subViewVerticalSpace.constant -= -200;
        
        [self layoutIfNeeded];
    }];
}

- (bool) isGroup
{
    return groupedMessages != nil;
}

@end
