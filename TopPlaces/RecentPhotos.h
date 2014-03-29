//
//  RecentPhotos.h
//  TopPlaces
//
//  Created by Kyle Adams on 29-03-14.
//  Copyright (c) 2014 Kyle Adams. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecentPhotos : NSObject

+ (NSArray *)fetchRecentPhotos;
+ (void)savePhotoToRecentPhotos:(NSDictionary *)photo;

@end
