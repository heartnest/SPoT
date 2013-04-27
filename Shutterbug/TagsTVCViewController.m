//
//  TagsTVCViewController.m
//  Shutterbug
//
//  Created by HeartNest on 7/4/13.
//  Copyright (c) 2013 HeartNest. All rights reserved.
//
//  Class for the Stanford tags
//

#import "TagsTVCViewController.h"
#import "FlickrFetcher.h"

@interface TagsTVCViewController ()

@end

@implementation TagsTVCViewController

#pragma mark - Table view life cycle

- (void)viewDidLoad
{
    [self loadStanfordPhotos];
}


#pragma mark - table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tags count];
}

-(NSString *)titleForRow:(NSUInteger)row{
    return [self.tags[row] capitalizedString];
}

-(NSString *)subTitleForRow:(NSUInteger)row{
    return [[self.tagStore objectForKey:self.tags[row]] stringByAppendingString:@"photos"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flicker Tag";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [self titleForRow:indexPath.row];
    cell.detailTextLabel.text = [self subTitleForRow:indexPath.row];
    return cell;
}



#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Show photo by tag"]) {
                
                if ([segue.destinationViewController respondsToSelector:@selector(setPhotos:)]) {
                    
                    NSString *tag = self.tags[indexPath.row];
                    
                    NSMutableArray *selectedPhotos = [[NSMutableArray alloc]init];
                    //look through the photos and add those with selected tag
                    for(NSDictionary *ft in self.photos){
                        NSString *tags = [ft objectForKey:@"tags"];
                        NSRange r = [tags rangeOfString:tag];
                        if(r.location != NSNotFound){
                            [selectedPhotos addObject:ft];
                        }
                    }
                    NSArray *preparedarr = [selectedPhotos copy];
                    //push the photos selected
                    [segue.destinationViewController performSelector:@selector(setPhotos:) withObject:preparedarr];
                    [segue.destinationViewController setTitle:[self titleForRow:indexPath.row]];
                }
            }
        }
    }
}


#pragma mark - utilities

-(void)loadStanfordPhotos{
    NSArray *sph = [FlickrFetcher stanfordPhotos];//assignment 4
    self.photos = sph;//assignment 4
}

//assignment 4, extract the tags and calculate occorrences
-(void)tagAnalyzer:(NSString *) tags{
    //split the tags
    NSArray *arr = [tags componentsSeparatedByString:@" "];
    for(NSString *tmp in arr){
        
        //trim
        NSString *tag = [tmp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if(![tag isEqualToString: @"cs193pspot"]&& ![tag isEqualToString: @"portrait"] && ![tag isEqualToString: @"landscape"] ){
            int counter = [[self.tagStore objectForKey:tag] intValue];
            
            if(counter != 0){
                counter++;
                [self.tagStore setObject:[NSString stringWithFormat:@"%d",counter] forKey:tag];
            }else{
                [self.tagStore setObject:@"1" forKey:tag];
            }
        }
        
    }
    
}

#pragma mark - properties //assignment 4

- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    for(NSDictionary *tmp in self.photos){
        NSString *tags = [tmp objectForKey:@"tags"];
        [self tagAnalyzer:tags];
    }
    self.tags = [self.tagStore allKeys];
    
    [self.tableView reloadData];
}

-(NSMutableDictionary *)tagStore{
    if(!_tagStore)
        _tagStore = [[NSMutableDictionary alloc]init];
    
    return  _tagStore;
}



@end
