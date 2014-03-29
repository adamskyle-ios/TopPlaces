//
//  RecentPhotosTVC.m
//  TopPlaces
//
//  Created by Kyle Adams on 29-03-14.
//  Copyright (c) 2014 Kyle Adams. All rights reserved.
//

#import "RecentPhotosTVC.h"
#import "RecentPhotos.h"

@implementation RecentPhotosTVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self fetchRecentPhotos];
}

- (IBAction)fetchRecentPhotos
{
    [self.refreshControl beginRefreshing];
    self.photos = [RecentPhotos fetchRecentPhotos];
    [self.refreshControl endRefreshing];
}

@end
