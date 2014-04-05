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
    id<HJMessageBubbleViewDelegate> delegate;
}
@synthesize objectData;

- (void) awakeFromNib
{
    isExpanded = FALSE;

}

- (void) setDelegate:(id<HJMessageBubbleViewDelegate>) newDelegate
{
    delegate = newDelegate;
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
    
    [self.messageTextView setText:[data valueForKey:@"message"]];
    [self.messageTextView setFont:[UIFont fontWithName:@"Gill Sans" size:15.0f]];

    [self resizeToFitText];
    
    [self.usersNameLabel setText:[data valueForKey:@"usersName"]];
}

- (void) resizeByHeight:(int)height
{
    CGRect frame = self.layer.frame;
    frame.size.height += height;
    frame.origin.y -= height;
    self.layer.frame = frame;
    
    self.centerOffset = CGPointMake(self.layer.frame.size.width/2, -self.layer.frame.size.height/2);

    [self layoutIfNeeded];
}

- (void) resizeToFitText
{
    [self layoutIfNeeded];
    
    CGSize rect = [self.messageTextView sizeThatFits:CGSizeMake(self.messageTextView.frame.size.width, FLT_MAX)];
    
    int resize = rect.height + 85 - (self.layer.frame.size.height);
    [self resizeByHeight:resize];
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
    [self->delegate didTouchButton:self];
//    if (groupedMessages == nil)
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
        [self resizeByHeight:200];
    }];
}
- (void) contract
{
    [UIView animateWithDuration:0.3 animations:^{
        [self resizeByHeight:-200];
    }];
}

- (bool) isGroup
{
    return groupedMessages != nil;
}

@end
