//
//  RecentPhotos.m
//  TopPlaces
//
//  Created by Kyle Adams on 29-03-14.
//  Copyright (c) 2014 Kyle Adams. All rights reserved.
//

#import "RecentPhotos.h"

@implementation RecentPhotos

+ (NSArray *)fetchRecentPhotos
{
    NSArray *photos = [[[NSUserDefaults standardUserDefaults] objectForKey:@"recent_photos"] mutableCopy];
    if (!photos) {
        photos = [[NSArray alloc] init];
    }
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"date_added" ascending:NO];

    return [photos sortedArrayUsingDescriptors:@[descriptor]];
}

+ (void)savePhotoToRecentPhotos:(NSMutableDictionary *)photo
{
    [photo setObject:[NSDate date] forKey:@"date_added"];
    NSMutableArray *recentPhotos = [[NSMutableArray alloc] initWithArray:[self fetchRecentPhotos]];
    if (![recentPhotos firstObject]) {
        [recentPhotos addObject:photo];
    } else {
        while ([recentPhotos count] >= 20) {
            [recentPhotos removeLastObject];
        }
        
        NSInteger duplicateIndex = 0;
        BOOL duplicate = NO;
        for (NSDictionary *recentPhoto in recentPhotos) {
            if (recentPhoto[@"id"] == photo[@"id"]){
                duplicateIndex = [recentPhotos indexOfObject:recentPhoto];
                duplicate = YES;
            }
        }
        
        if (duplicate) {
            [recentPhotos replaceObjectAtIndex:duplicateIndex withObject:photo];
        } else {
            [recentPhotos addObject:photo];
        };
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:recentPhotos forKey:@"recent_photos"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
