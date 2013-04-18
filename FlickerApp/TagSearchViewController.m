//
//  TagSearchViewController.m
//  FlickerApp
//
//  Created by Rincewind on 25.01.13.
//  Copyright (c) 2013 Rincewind. All rights reserved.
//

#import "TagSearchViewController.h"
#import "TagPictureViewController.h"
#import "Place.h"
#import "Photo.h"
#import "HelperClass.h"
#import "Tag.h"

@interface TagSearchViewController ()

@property NSArray *sortedtags;
@property (nonatomic) UIManagedDocument *database;
@property NSMutableArray *filteredTags;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation TagSearchViewController

@synthesize sortedtags = _sortedtags;
@synthesize database = _database;
@synthesize filteredTags = _filteredTags;
@synthesize searchBar=_searchBar;
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

-(void) getData{
    
    NSFetchRequest *tagRequest = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO];
    tagRequest.sortDescriptors = [NSArray arrayWithObject:sort];
    
    self.sortedtags = [self.database.managedObjectContext executeFetchRequest:tagRequest error:nil];
    
    self.filteredTags = [NSMutableArray arrayWithCapacity:[self.sortedtags count]];
   
    [self.tableView reloadData];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.filteredTags count];
    } else {
        return [self.sortedtags count];
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TagSearchCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    Tag *t =nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        t= [self.filteredTags objectAtIndex:indexPath.row];
    } else {
        t = self.sortedtags [indexPath.row];
    }
    cell.textLabel.text = t.name;
    int n =[t.count intValue];
    NSString *times;
    if (n>1) times =@"times";
    else times =@"time";
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Tag found %d %@", n,times];
    
    return cell;
}


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
    if(tableView == self.searchDisplayController.searchResultsTableView) {
    [self performSegueWithIdentifier:@"TagSegue" sender:tableView];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"TagSegue"]){
        if(sender == self.searchDisplayController.searchResultsTableView) {
            NSIndexPath *selectedRowIndex = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            Tag *t = self.filteredTags[selectedRowIndex.row];
            TagPictureViewController *tp = segue.destinationViewController;
            tp.tag=t;
            tp.database =self.database;
        }
        else {
            NSIndexPath *selectedRowIndex = [self.tableView indexPathForSelectedRow];
            Tag *t = self.sortedtags[selectedRowIndex.row];
            TagPictureViewController *tp = segue.destinationViewController;
            tp.tag=t;
            tp.database =self.database;
        }
    }
}

#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Remove all objects from the filtered search array
    [self.filteredTags removeAllObjects];
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[c] %@",searchText];
    self.filteredTags = [NSMutableArray arrayWithArray:[self.sortedtags filteredArrayUsingPredicate:predicate]];
}

#pragma mark - UISearchDisplayController Delegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

@end
