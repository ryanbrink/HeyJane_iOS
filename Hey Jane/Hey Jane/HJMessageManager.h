//
//  HJMessageManager.h
//  Hey Jane
//
//  Created by Ryan Brink on 2014-03-13.
//  Copyright (c) 2014 HeyJane. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/Mapkit.h>

typedef void (^HJMessageSaveCallback)(bool succeeded);
typedef void (^HJMessageReceivedCallback)(bool succeeded, NSArray *messages);

@interface HJMessageManager : NSObject
+(HJMessageManager *)sharedInstance;
- (void) saveInBackgroundMessage:(NSString *) message withLocation:(CLLocation *) location withCompletionBlock:(HJMessageSaveCallback) block;
- (void) getMessagesInBackgroundNearLocation:(CLLocation *) location withCompletionBlock:(HJMessageReceivedCallback) block;
@end
