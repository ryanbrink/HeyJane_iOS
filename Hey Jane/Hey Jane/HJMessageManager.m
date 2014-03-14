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
{
    NSUserDefaults *userDefaults;
}

+(HJMessageManager *)sharedInstance
{
    static dispatch_once_t pred;
    static HJMessageManager *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[HJMessageManager alloc] init];
    });
    return sharedInstance;
}

- (id) init
{
    self = [super init];
    
    if (self != nil)
    {
        self->userDefaults = [NSUserDefaults standardUserDefaults];
    }
    
    return self;
}

- (void) saveInBackgroundMessage:(NSString *) message withLocation:(CLLocation *) location withCompletionBlock:(HJMessageSaveCallback) block
{
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    PFObject *messageObject = [PFObject objectWithClassName:PARSE_MESSAGE_CLASS_NAME];
    [messageObject setObject:point forKey:@"location"];
    [messageObject setObject:message forKey:@"message"];
    [messageObject setObject:[self->userDefaults stringForKey:@"usersName"] forKey:@"usersName"];
    [messageObject setObject:[NSNumber numberWithInt:0] forKey:@"votes"];
    [messageObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error != nil)
        {
            NSLog(@"%@", error);
        }
        block(succeeded);
    }];
}

- (NSInteger) getNumberOfMessagesWithin:(int) kilometers ofPoint:(PFGeoPoint *) point withError:(NSError *__autoreleasing *) error
{
    PFQuery *query = [PFQuery queryWithClassName:PARSE_MESSAGE_CLASS_NAME];
    [query orderByDescending:@"votes"];
    [query addAscendingOrder:@"createdAt"];
    [query setLimit:15];
    [query whereKey:@"location" nearGeoPoint:point withinKilometers:kilometers];
    NSInteger numberOfMessages = [query countObjects];
    return numberOfMessages;
}

- (void) getApproximateRadiusInKilometersToRevealTenMessagesAroundCoordinate:(CLLocationCoordinate2D) location withCompletionBlock:(HJMessageDistanceFoundCallback) block
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // Do a number of queries that try to find the radius around the centerpoint that will reveal around 10 of the most popular messages
        
        PFGeoPoint *currentLocation = [PFGeoPoint geoPointWithLatitude:location.latitude
                                                             longitude:location.longitude];
        NSError *__autoreleasing * error;
        NSInteger numberOfMessages;
//        NSInteger lastNumberOfMessages = -1;
        int kilometersToQuery = 1;
        
        // Try 10 times to find the right number of clicks to scale
        int attempts;
        for (attempts = 10; attempts > 0; attempts--)
        {
            numberOfMessages = [self getNumberOfMessagesWithin:kilometersToQuery ofPoint:currentLocation withError:error];
            
//            if (*error)
//            {
//                NSLog(@"%@", *error);
//                return;
//            }
            
            if (numberOfMessages > 25)
            {
                kilometersToQuery /= 2;
            }
            else if (numberOfMessages < 5)
            {
                kilometersToQuery *= 10;
            }
            else
            {
                break;
            }
        }
        NSLog(@"Made %d attmpts.", attempts);
        dispatch_async(dispatch_get_main_queue(), ^{
            block(YES, [NSNumber numberWithInt:kilometersToQuery]);
        });
    });
}

- (void) getMessagesInBackgroundWithin:(int) kilometers nearLocation:(CLLocationCoordinate2D) location withCompletionBlock:(HJMessageReceivedCallback) block
{
    PFGeoPoint *currentLocation = [PFGeoPoint geoPointWithLatitude:location.latitude
                                                         longitude:location.longitude];
    
    PFQuery *query = [PFQuery queryWithClassName:PARSE_MESSAGE_CLASS_NAME];
    [query orderByDescending:@"votes"];
    [query addAscendingOrder:@"createdAt"];
    [query setLimit:15];
    [query whereKey:@"location" nearGeoPoint:currentLocation withinKilometers:kilometers];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error != nil)
        {
            NSLog(@"%@", error);
        }
        
        block(error == nil, objects);
    }];
}

@end
