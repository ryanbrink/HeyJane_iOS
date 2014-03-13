//
//  HJMessageManager.m
//  Hey Jane
//
//  Created by Ryan Brink on 2014-03-13.
//  Copyright (c) 2014 HeyJane. All rights reserved.
//

#import "HJMessageManager.h"
#import <Parse/Parse.h>

#define PARSE_MESSAGE_CLASS_NAME @"Message"

@implementation HJMessageManager

+(HJMessageManager *)sharedInstance
{
    static dispatch_once_t pred;
    static HJMessageManager *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[HJMessageManager alloc] init];
    });
    return sharedInstance;
}

- (void) saveInBackgroundMessage:(NSString *) message withLocation:(CLLocation *) location withCompletionBlock:(HJMessageSaveCallback) block
{
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    PFObject *messageObject = [PFObject objectWithClassName:PARSE_MESSAGE_CLASS_NAME];
    [messageObject setObject:point forKey:@"location"];
    [messageObject setObject:message forKey:@"message"];
    [messageObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error != nil)
        {
            NSLog(@"%@", error);
        }
        block(succeeded);
    }];
}

- (void) getMessagesInBackgroundNearLocation:(CLLocation *) location withCompletionBlock:(HJMessageReceivedCallback) block
{
    PFGeoPoint *currentLocation = [PFGeoPoint geoPointWithLatitude:location.coordinate.latitude
                                                         longitude:location.coordinate.longitude];
    
    PFQuery *query = [PFQuery queryWithClassName:PARSE_MESSAGE_CLASS_NAME];
    [query orderByAscending:@"createdAt"];
    [query whereKey:@"location" nearGeoPoint:currentLocation withinKilometers:10];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error != nil)
        {
            NSLog(@"%@", error);
        }
        
        block(error == nil, objects);
    }];
}

@end
