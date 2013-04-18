//
//  ItineraryViewController.m
//  FlickerApp
//
//  Created by Rincewind on 24.01.13.
//  Copyright (c) 2013 Rincewind. All rights reserved.
//

#import "ItineraryViewController.h"
#import "Place.h"
#import "Photo.h"
#import "FavPlacesViewController.h"
#import "HelperClass.h"

@interface ItineraryViewController ()

@property (strong, nonatomic) UIManagedDocument *database;

@end

@implementation ItineraryViewController

@synthesize places = _places;
@synthesize database = _database;
@synthesize databaseName =_databaseName;

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.database = [HelperClass database:self.databaseName];
   
    
    
    
}
- (void)openDocument
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.database.fileURL path]]) {
        // does not exist on disk, so create it
        [self.database saveToURL:self.database.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            [self getData];
            
        }];
    } else if (self.database.documentState == UIDocumentStateClosed) {
        // exists on disk, but we need to open it
        [self.database openWithCompletionHandler:^(BOOL success) {
           [self getData];
        }];
    } else if (self.database.documentState == UIDocumentStateNormal) {
        [self getData];
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
- (void) getData{
    
    NSFetchRequest *placeRequest = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timeAdded"
                                                                     ascending:YES];
    placeRequest.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:placeRequest
                                                                        managedObjectContext:self.database.managedObjectContext
                                                                          sectionNameKeyPath:nil                                                       cacheName:nil];
    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ItineraryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Place *p = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text=p.location;
    
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"FavPlacesSegue"]){
        NSIndexPath *selectedRowIndex = [self.tableView indexPathForSelectedRow];
        Place *p = [self.fetchedResultsController objectAtIndexPath:selectedRowIndex];
        FavPlacesViewController *fp = segue.destinationViewController;
        fp.place = p;
        fp.database =self.database;
    
    }

}



@end
