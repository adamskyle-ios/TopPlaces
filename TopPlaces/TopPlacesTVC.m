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

@interface TopPlacesTVC ()

@property (strong, nonatomic) NSArray *places;
@property (strong, nonatomic) NSArray *countries;
@property (strong, nonatomic) NSDictionary *placesByCountry;

@end

@implementation TopPlacesTVC

- (void)setPlaces:(NSArray *)places
{
    _places = places;
    [self fetchAndSortByCountries];
}

- (void)setCountries:(NSArray *)countries
{
    _countries = countries;
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchPhotos];
}

- (void)fetchAndSortByCountries
{
    // Set up the array of top places, organised by place descriptions
    NSArray *topPlaces = [self.places sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:FLICKR_PLACE_NAME ascending:YES]]];
    NSMutableDictionary *placesByCountry = [[NSMutableDictionary alloc] init];
    
    for (NSDictionary *place in topPlaces) {
        NSString *country = [FlickrFetcher extractCountryNameFromPlaceInformation:place];
        // If the country isn't already in the dictionary, add it with a new array
        if (![placesByCountry objectForKey:country]) {
            [placesByCountry setObject:[NSMutableArray array] forKey:country];
        }
        // Add the place to the countries' value array
        if ([placesByCountry[country] isKindOfClass:[NSMutableArray class]]) {
            [placesByCountry[country] addObject:place];
        }
    }
    
    // Set the place by country
    self.placesByCountry = placesByCountry;
    
    // Set up the section headers in alphabetical order
    self.countries = [[placesByCountry allKeys] sortedArrayUsingSelector:
                           @selector(caseInsensitiveCompare:)];
    
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.countries count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.countries[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.placesByCountry[self.countries[section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Flickr Place";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    // Configure the cell..
    NSArray *countries = self.placesByCountry[self.countries[indexPath.section]];
	NSDictionary *topPlaceDictionary = countries[indexPath.row];
	NSArray *placeNameComponents = [[topPlaceDictionary objectForKey:FLICKR_PLACE_NAME] componentsSeparatedByString:@", "];
    
    cell.textLabel.text = placeNameComponents[0];
    cell.detailTextLabel.text = placeNameComponents[1];
    
    return cell;
}


#pragma mark - Navigation

- (void)preparePhotosForPlaceTVC:(PhotosForPlaceTVC*)ptvc toListPhotosForPlace:(NSDictionary *)place
{
    NSLog(@"%@", place);
    ptvc.placeURL = [FlickrFetcher URLforPhotosInPlace:place[FLICKR_PLACE_ID] maxResults:50];
    ptvc.title = place[FLICKR_PLACE_NAME];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqual:@"Photos For Place"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSArray *countries = self.placesByCountry[self.countries[indexPath.section]];
        [self preparePhotosForPlaceTVC:segue.destinationViewController toListPhotosForPlace:countries[indexPath.row]];
    }
}


@end
