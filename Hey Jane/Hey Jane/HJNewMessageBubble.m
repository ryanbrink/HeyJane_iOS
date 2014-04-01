//
//  HJNewMessageBubble.m
//  Hey Jane
//
//  Created by Ryan Brink on 2014-04-01.
//  Copyright (c) 2014 HeyJane. All rights reserved.
//

#import "HJNewMessageBubble.h"
#import "HJMessageManager.h"

@implementation HJNewMessageBubble
{
    id<HJNewMessageBubbleDelegate> delegate;
}

- (void) awakeFromNib
{
    [self.messageTextView setDelegate:self];
    
    CGRect frame = self.layer.frame;
    frame.size.height = 200;
    self.layer.frame = frame;
    
    UITapGestureRecognizer *viewTouch =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(didTouchView:)];
    [self addGestureRecognizer:viewTouch];
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

- (void) didTouchView:(id)sender {
    [self->delegate didTapView];
}

- (IBAction)didPressGo:(id)sender {
    [delegate didFinishWithMessage:self.messageTextView.text];
}

- (void) setDelegate:(id<HJNewMessageBubbleDelegate>)newDelegate
{
    self->delegate = newDelegate;
}

@end
