//
//  TagsPhotoTVCViewController.m
//  Shutterbug
//
//  Created by HeartNest on 7/4/13.
//  Copyright (c) 2013 HeartNest. All rights reserved.
//

#import "TagsPhotoTVCViewController.h"
#import "FlickrFetcher.h"

@interface TagsPhotoTVCViewController ()

@end

@implementation TagsPhotoTVCViewController


-(void)setPhotos:(NSArray *)photos{
    _photos = photos;
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

                    NSURL *url = [FlickrFetcher urlForPhoto:self.photos[indexPath.row] format:FlickrPhotoFormatLarge];
                    
                    [self synchronize:self.photos[indexPath.row]];//assignment 4
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
    return [self.photos count];
}

//title
-(NSString *)titleForRow:(NSUInteger)row{
    return [self.photos[row][FLICKR_PHOTO_TITLE] description];//description round null in nil
}

//subtitle
-(NSString *)subTitleForRow:(NSUInteger)row{
    NSDictionary *descri = (NSDictionary *)[self.photos[row] objectForKey:@"description"];
    NSString *description  = [descri objectForKey:@"_content"];
    return [description capitalizedString];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flicker Photo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [self titleForRow:indexPath.row];
    cell.detailTextLabel.text = [self subTitleForRow:indexPath.row];
    return cell;
}
                     
#pragma mark - UserDefaults implementation
                     
#define ALL_VIEWED_KEY @"recent"
#define PHOTO_VIEWED_TIMES @"photoviewedtime"
//store the viewed photos in user defaults, assignment 4
-(void)synchronize:(NSDictionary *)photo{
    //get photo id
    id photo_id = [photo objectForKey:@"id"];
    
    NSMutableDictionary *mutableViewedPhotoFromUserDefaults = [[[NSUserDefaults standardUserDefaults] dictionaryForKey: ALL_VIEWED_KEY] mutableCopy];//inherit the last one
    if(!mutableViewedPhotoFromUserDefaults)//if need creation
    mutableViewedPhotoFromUserDefaults = [[NSMutableDictionary alloc]init];
 
    if (mutableViewedPhotoFromUserDefaults[photo_id] ==nil) {//if photo does not exsits
        mutableViewedPhotoFromUserDefaults[photo_id]=photo;//assign content
        [mutableViewedPhotoFromUserDefaults[photo_id] setObject:@"1" forKey:PHOTO_VIEWED_TIMES];
    }else{
        //increment the viewed time of the photo
        int viewed = [[mutableViewedPhotoFromUserDefaults[photo_id] objectForKey:PHOTO_VIEWED_TIMES] intValue];
        viewed++;
        //modify
        NSMutableDictionary *tmpdic = [mutableViewedPhotoFromUserDefaults[photo_id] mutableCopy];
        [tmpdic setObject:[[NSString alloc]initWithFormat:@"%d",viewed] forKey:PHOTO_VIEWED_TIMES];
        [mutableViewedPhotoFromUserDefaults setObject:tmpdic forKey:photo_id];
    }

    [[NSUserDefaults standardUserDefaults]setObject:mutableViewedPhotoFromUserDefaults forKey:ALL_VIEWED_KEY];//change
    [[NSUserDefaults standardUserDefaults]synchronize];//save datas
    

}

@end
