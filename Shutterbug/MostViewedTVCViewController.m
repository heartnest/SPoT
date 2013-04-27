//
//  MostViewedTVCViewController.m
//  Shutterbug
//
//  Created by HeartNest on 7/4/13.
//  Copyright (c) 2013 HeartNest. All rights reserved.
//

#import "MostViewedTVCViewController.h"
#import "FlickrFetcher.h"

@interface MostViewedTVCViewController ()

@end

@implementation MostViewedTVCViewController


#pragma mark - View Controller Lifecycle

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateUI];
}


-(void)setMostViewedPhotos:(NSArray *)photos{
    _mostViewedPhotos = photos;
    [self.tableView reloadData];
}

#define MAX_VIEWED_SHOWN 10
#define ALL_VIEWED_KEY @"recent"
#define PHOTO_TITLE @"cached_phototitle"
#define PHOTO_ID @"cached_photoid"
#define PHOTO_DESCRIPTION @"cached_photodescription"
#define PHOTO_VIEWED_TIMES @"photoviewedtime"

-(void)updateUI{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    //get photos from user defaults
    for(id plist in[[[NSUserDefaults standardUserDefaults] dictionaryForKey:ALL_VIEWED_KEY]allValues]){
        [arr addObject:plist];
    }
    
    //Order photos using descriptor
    NSSortDescriptor *viewedDescriptor = [[NSSortDescriptor alloc]initWithKey:PHOTO_VIEWED_TIMES ascending:NO];
    NSArray *descriptors = @[viewedDescriptor];
    NSArray *sorted = [arr sortedArrayUsingDescriptors:descriptors];
    NSMutableArray *selected = [[NSMutableArray alloc]init];
    
    //show a limit number of photos
    for(int i=0; (i<sorted.count && i<MAX_VIEWED_SHOWN);i++){
        [selected addObject:sorted[i]];
    }
    
    self.mostViewedPhotos = [[NSArray alloc]initWithArray:selected];
}



#pragma mark - Segue

// prepares for the "Show Image" segue by seeing if the destination view controller of the segue
//  understands the method "setImageURL:"
// if it does, it sends setImageURL: to the destination view controller with
//  the URL of the photo that was selected in the UITableView as the argument
// also sets the title of the destination view controller to the photo's title

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Show Image"]) {
                
                if ([segue.destinationViewController respondsToSelector:@selector(setImageURL:)]) {
                    NSURL *url = [FlickrFetcher urlForPhoto:self.mostViewedPhotos[indexPath.row] format:FlickrPhotoFormatLarge];
                    [segue.destinationViewController performSelector:@selector(setImageURL:) withObject:url];
                    [segue.destinationViewController setTitle:[self titleForRow:indexPath.row]];
                }
            }
        }
    }
}



#pragma mark - Table view data source

//colon number
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.mostViewedPhotos count];
}

//title
-(NSString *)titleForRow:(NSUInteger)row{
    return [self.mostViewedPhotos[row][FLICKR_PHOTO_TITLE] description];//description round null in nil
}

//subtitle
-(NSString *)subTitleForRow:(NSUInteger)row{
    NSDictionary *descri = (NSDictionary *)[self.mostViewedPhotos[row] objectForKey:@"description"];
    NSString *description  = [descri objectForKey:@"_content"];
    NSString *viewedtime = [self.mostViewedPhotos[row] objectForKey:PHOTO_VIEWED_TIMES]?[self.mostViewedPhotos[row] objectForKey:PHOTO_VIEWED_TIMES] : @"1" ;
    return [[[NSString alloc]initWithFormat:@"%@ %@ times", description,viewedtime] capitalizedString];
    return description;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flicker Photo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [self titleForRow:indexPath.row];
    cell.detailTextLabel.text = [self subTitleForRow:indexPath.row];
    return cell;
}


@end
