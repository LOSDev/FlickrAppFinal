//
//  FavoritesViewController.m
//  FlickerApp
//
//  Created by Rincewind on 24.01.13.
//  Copyright (c) 2013 Rincewind. All rights reserved.
//

#import "FavoritesViewController.h"
#import "StaticTableViewController.h"
#import "HelperClass.h"


@interface FavoritesViewController () <UIAlertViewDelegate>

@property NSArray *dirContents;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
- (IBAction)addVacation:(id)sender;
@end

@implementation FavoritesViewController

@synthesize dirContents = _dirContents;

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
    [self loadVacations];
    
}
-(void) loadVacations{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    self.dirContents = [[NSFileManager defaultManager]
                        contentsOfDirectoryAtPath:documentsPath error:nil];
    NSMutableArray *result = [NSMutableArray array];
    BOOL isDir;
    for (NSString *file in self.dirContents) {
        
        if([[NSFileManager defaultManager] fileExistsAtPath:[[paths objectAtIndex:0]
                                                             stringByAppendingPathComponent:file]
                                                isDirectory:&isDir] && isDir){
            
            [result addObject:file];
        }
    }
    self.dirContents = [result mutableCopy];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return [self.dirContents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FavoriteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = self.dirContents[indexPath.row];
    
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
    if ([segue.identifier isEqualToString:@"SegueToStatic"]){
        
        NSIndexPath *selectedRowIndex = [self.tableView indexPathForSelectedRow];
        StaticTableViewController *stat =segue.destinationViewController;
        
        stat.databaseName= self.dirContents[selectedRowIndex.row];
    }
}

- (IBAction)addVacation:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please Enter new Vacation name" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
    // optional - add more buttons:
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
   
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        NSString *filename =[alertView textFieldAtIndex:0].text;
        
        UIManagedDocument *doc = [HelperClass database:filename];
       
        if (![[NSFileManager defaultManager] fileExistsAtPath:[doc.fileURL path]]) {
            // does not exist on disk, so create it
            [doc saveToURL:doc.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
                [self loadVacations];
                [self.tableView reloadData];
                
            }];
        } else if (doc.documentState == UIDocumentStateClosed) {
            // exists on disk, but we need to open it
            [doc openWithCompletionHandler:^(BOOL success) {
                [self loadVacations];
                [self.tableView reloadData];
            }];
        } else if (doc.documentState == UIDocumentStateNormal) {
            [self loadVacations];
            [self.tableView reloadData];
        }
    }    
}


@end
