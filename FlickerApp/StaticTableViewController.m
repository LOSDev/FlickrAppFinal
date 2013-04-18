//
//  StaticTableViewController.m
//  FlickerApp
//
//  Created by Rincewind on 24.01.13.
//  Copyright (c) 2013 Rincewind. All rights reserved.
//

#import "StaticTableViewController.h"
#import "PhotoDetailViewController.h"
#import <CoreData/CoreData.h>
#import "Place.h"
#import "Photo.h"
#import "ItineraryViewController.h"
#import "TagSearchViewController.h"
#import "HelperClass.h"

@interface StaticTableViewController ()

@end

@implementation StaticTableViewController
@synthesize databaseName;
@synthesize database;

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
    
    self.database = [HelperClass database:databaseName];
     
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"ItinerarySegue"]) {
        ItineraryViewController *it =segue.destinationViewController;
        it.databaseName = self.databaseName;
    }else{
        TagSearchViewController *ts =segue.destinationViewController;
        ts.databaseName = self.databaseName;
    }
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
    
            
}



@end
