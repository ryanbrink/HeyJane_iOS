//
//  HJNewMessageBubble.h
//  Hey Jane
//
//  Created by Ryan Brink on 2014-04-01.
//  Copyright (c) 2014 HeyJane. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HJNewMessageBubbleDelegate <NSObject>

- (void) didTapView;
- (void) didFinishWithMessage:(NSString *) message;

@end

@interface HJNewMessageBubble : UIView <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UITextView *titleTextView;

- (void) setDelegate:(id<HJNewMessageBubbleDelegate>)newDelegate;

@end
