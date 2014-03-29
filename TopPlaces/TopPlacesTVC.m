//
//  TopPlacesTVC.m
//  TopPlaces
//
//  Created by Kyle Adams on 27-03-14.
//  Copyright (c) 2014 Kyle Adams. All rights reserved.
//

#import "TopPlacesTVC.h"
#import "FlickrFetcher.h"
#import "PhotosForPlaceTVC.h"

@implementation TopPlacesTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchPhotos];
}

- (IBAction)fetchPhotos
{
    [self.refreshControl beginRefreshing];
    NSURL *url = [FlickrFetcher URLforTopPlaces];
    
    dispatch_queue_t fetchQ = dispatch_queue_create("flickr fetcher", NULL);
    dispatch_async(fetchQ, ^{
        NSData *jsonResults = [NSData dataWithContentsOfURL:url];
        NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResults options:0 error:NULL];
        NSArray *places = [propertyListResults valueForKeyPath:FLICKR_RESULTS_PLACES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
            self.places = places;
        });
    });
}

@end
