//
//  TagPictureViewController.m
//  FlickerApp
//
//  Created by Rincewind on 25.01.13.
//  Copyright (c) 2013 Rincewind. All rights reserved.
//

#import "TagPictureViewController.h"
#import "PhotoDetailViewController.h"
#import "Photo.h"
#import "HelperClass.h"


@interface TagPictureViewController ()

@property PhotoDetailViewController *detailVC;


@end

@implementation TagPictureViewController


@synthesize detailVC = _detailVC;
@synthesize database = _database;
@synthesize tag = _tag;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    id detail = [self.splitViewController.viewControllers lastObject];
    if ([detail isKindOfClass:[PhotoDetailViewController class]]) {
        self.detailVC = (PhotoDetailViewController *)detail;
    }
        
    self.title = self.tag.name;
    
    NSFetchRequest *placeRequest = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    placeRequest.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    placeRequest.predicate = [NSPredicate predicateWithFormat:@"tags contains[cd] %@",self.tag];
   
    self.fetchedResultsController =[[NSFetchedResultsController alloc]initWithFetchRequest:placeRequest
                                                                      managedObjectContext:self.database.managedObjectContext
                                                                        sectionNameKeyPath:nil
                                                                                 cacheName:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PhotoTagCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Photo *p = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = p.title;
    cell.detailTextLabel.text=p.subtitle;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Photo *p = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if(p.title)[dict setObject:p.title forKey:@"title"];
    [dict setObject:p.uniqueId forKey:@"id"];
    if(p.subtitle) [dict setObject:p.subtitle forKey:@"description._content"];
    [dict setObject:p.farm forKey:@"farm"];
    [dict setObject:p.server forKey:@"server"];
    [dict setObject:p.secret forKey:@"secret"];
   
    self.detailVC.photo = dict;
}

@end
