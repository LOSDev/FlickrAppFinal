//
//  FavPlacesViewController.m
//  FlickerApp
//
//  Created by Rincewind on 25.01.13.
//  Copyright (c) 2013 Rincewind. All rights reserved.
//

#import "FavPlacesViewController.h"
#import "PhotoDetailViewController.h"
#import "Photo.h"
#import "Place.h"
#import "HelperClass.h"


@interface FavPlacesViewController ()


@property PhotoDetailViewController *detailVC;

@end

@implementation FavPlacesViewController

@synthesize place = _place;
@synthesize database = _database;
@synthesize detailVC = _detailVC;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)openDocument
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.database.fileURL path]]) {
        // does not exist on disk, so create it
        [self.database saveToURL:self.database.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            
            
        }];
    } else if (self.database.documentState == UIDocumentStateClosed) {
        // exists on disk, but we need to open it
        [self.database openWithCompletionHandler:^(BOOL success) {
          
        }];
    } else if (self.database.documentState == UIDocumentStateNormal) {
       
    }
}

// 2. Make the photoDatabase's setter start using it

- (void)setDatabase:(UIManagedDocument *)photoDatabase
{
    if (_database != photoDatabase) {
        _database = photoDatabase;
        [self openDocument];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    id detail = [self.splitViewController.viewControllers lastObject];
    if ([detail isKindOfClass:[PhotoDetailViewController class]]) {
        self.detailVC = (PhotoDetailViewController *)detail;
    }
    //self.database = [HelperClass database];
    
    NSFetchRequest *placeRequest = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    placeRequest.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    placeRequest.predicate = [NSPredicate predicateWithFormat:@"location = %@",self.place];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:placeRequest
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
    static NSString *CellIdentifier = @"FavPlacesCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Photo *p = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text=p.title;
    cell.detailTextLabel.text =p.subtitle;
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
    Photo *p= [self.fetchedResultsController objectAtIndexPath:indexPath];
   
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:p.title forKey:@"title"];
    [dict setObject:p.uniqueId forKey:@"id"];
    if(p.subtitle) [dict setObject:p.subtitle forKey:@"description._content"];
    [dict setObject:p.farm forKey:@"farm"];
    [dict setObject:p.server forKey:@"server"];
    [dict setObject:p.secret forKey:@"secret"];
    Place *pl =p.location;
    [dict setObject:pl.location forKey:@"derived_place"];
    
    self.detailVC.photo = dict;
}

@end
