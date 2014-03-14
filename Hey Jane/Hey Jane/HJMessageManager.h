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
typedef void (^HJMessageDistanceFoundCallback)(bool succeeded, NSNumber *kilometers);

@interface HJMessageManager : NSObject
+(HJMessageManager *)sharedInstance;
- (void) saveInBackgroundMessage:(NSString *) message withLocation:(CLLocation *) location withCompletionBlock:(HJMessageSaveCallback) block;
- (void) getMessagesInBackgroundWithin:(int) kilometers nearLocation:(CLLocationCoordinate2D) location withCompletionBlock:(HJMessageReceivedCallback) block;
- (void) getApproximateRadiusInKilometersToRevealTenMessagesAroundCoordinate:(CLLocationCoordinate2D) location withCompletionBlock:(HJMessageDistanceFoundCallback) block;
@end
