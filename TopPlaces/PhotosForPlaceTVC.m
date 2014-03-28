//
//  PhotosForPlaceTVC.m
//  TopPlaces
//
//  Created by Kyle Adams on 27-03-14.
//  Copyright (c) 2014 Kyle Adams. All rights reserved.
//

#import "PhotosForPlaceTVC.h"
#import "FlickrFetcher.h"
#import "ImageViewController.h"

@interface PhotosForPlaceTVC ()

@property (strong, nonatomic) NSArray *photos;

@end

@implementation PhotosForPlaceTVC

- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchPhotos];
}

- (IBAction)fetchPhotos
{
    if (self.placeURL) {
        [self.refreshControl beginRefreshing];
        NSURLRequest *request = [NSURLRequest requestWithURL:self.placeURL];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
            if (!error) {
                //make sure request url is not changed during queue
                if ([request.URL isEqual:self.placeURL]) {
                    NSDictionary *propertyListPhotos = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:location] options:0 error:NULL];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.refreshControl endRefreshing];
                        self.photos = [propertyListPhotos valueForKeyPath:FLICKR_RESULTS_PHOTOS];
                    });
                }
            }
        }];
        [task resume];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Flickr Photo" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [self.photos[indexPath.row] valueForKey:FLICKR_PHOTO_TITLE];
    cell.detailTextLabel.text = [self.photos[indexPath.row] valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    
    return cell;
}


#pragma mark - Navigation

 - (void)prepareImageViewController:(ImageViewController *)ivc toDisplayPhoto:(NSDictionary *)photo
 {
     ivc.imageURL = [FlickrFetcher URLforPhoto:photo format:FlickrPhotoFormatLarge];
     ivc.title = [photo valueForKeyPath:FLICKR_PHOTO_TITLE];
 }
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     if ([sender isKindOfClass:[UITableViewCell class]]) {
         NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
         if (indexPath) {
             if ([segue.identifier isEqualToString:@"Photo"]) {
                 if ([segue.destinationViewController isKindOfClass:[ImageViewController class]]) {
                     [self prepareImageViewController:segue.destinationViewController toDisplayPhoto:self.photos[indexPath.row]];
                 }
             }
         }
     }
}


@end
