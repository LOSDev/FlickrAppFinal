//
//  PhotoDetailViewController.m
//  FlickerApp
//
//  Created by Rincewind on 17.01.13.
//  Copyright (c) 2013 Rincewind. All rights reserved.
//

#import "PhotoDetailViewController.h"
#import "FlickrFetcher.h"
#import <CoreData/CoreData.h>
#import "Photo.h"
#import "Place.h"
#import "HelperClass.h"
#import "Tag.h"

@interface PhotoDetailViewController () <UITableViewDelegate,UITableViewDataSource,UIPopoverControllerDelegate>
@property (nonatomic, strong) UIPopoverController *pc;
@property NSArray *vacations;
@end

@implementation PhotoDetailViewController

@synthesize scrollViewWithImage;
@synthesize imageView=_imageView;
@synthesize imageURL = _imageURL;
@synthesize toolBar=_toolBar;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize photo = _photo;
@synthesize titleLabel =_titleLabel;
@synthesize activityIndi;
@synthesize photoDatabase =_photoDatabase;
@synthesize favButton = _favButton;
@synthesize pc = _pc;
@synthesize vacations =_vacations;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)openDocument
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.photoDatabase.fileURL path]]) {
        // does not exist on disk, so create it
        [self.photoDatabase saveToURL:self.photoDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            //[self setupFetchedResultsController];
            //[self fetchFlickrDataIntoDocument:self.photoDatabase];
            
        }];
    } else if (self.photoDatabase.documentState == UIDocumentStateClosed) {
        // exists on disk, but we need to open it
        [self.photoDatabase openWithCompletionHandler:^(BOOL success) {
            //[self setupFetchedResultsController];
        }];
    } else if (self.photoDatabase.documentState == UIDocumentStateNormal) {
        // already open and ready to use
        //[self setupFetchedResultsController];
    }
}

// 2. Make the photoDatabase's setter start using it

- (void)setPhotoDatabase:(UIManagedDocument *)photoDatabase
{
    if (_photoDatabase != photoDatabase) {
        _photoDatabase = photoDatabase;
        [self openDocument];
    }
}


- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    
    if (splitViewBarButtonItem != _splitViewBarButtonItem) {
        NSMutableArray *toolbarItems = [self.toolBar.items mutableCopy];
        if (_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
        if (splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
        self.toolBar.items = toolbarItems;
        _splitViewBarButtonItem = splitViewBarButtonItem;
    }
}

-(void) updatePreferences:(NSDictionary *) photo{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSMutableArray *lastPics= [[prefs objectForKey:@"lastPics"] mutableCopy];
    if(!lastPics) lastPics = [NSMutableArray array];
    if (![lastPics containsObject:photo]) {
        [lastPics insertObject:photo atIndex:0];
    }
    
    if ([lastPics count]>20) [lastPics removeLastObject];
    [prefs setObject:lastPics forKey:@"lastPics"];
    [prefs synchronize];
    
}

-(void)setPhoto:(NSDictionary *)photo{
    _photo=photo;
    self.scrollViewWithImage.zoomScale=1;
    [self.toolBar addSubview:activityIndi];
    UIBarButtonItem * barButton =
    [[UIBarButtonItem alloc] initWithCustomView:activityIndi];
    [self.navigationItem setRightBarButtonItem:barButton];
    [self.activityIndi startAnimating];
    [self updatePreferences:photo];
    [self updateImage];
    
    
    NSArray *frc = [self searchDbById];
    if ([frc count] == 0) {        
        [self.favButton setTitle:@"Visit"];
    }
    else {
        [self.favButton setTitle:@"Unvisit"];
        
    }
    
    
}

- (NSArray *) searchDbById{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"uniqueId = %@",[self.photo valueForKey:@"id"]];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title"
                                                                                     ascending:YES
                                                                                      selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    return [self.photoDatabase.managedObjectContext executeFetchRequest:request error:nil];
}

-(void) updateImage{
    if (self.photo) {
        
        
        NSString *applicationDocumentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *storePathPicture = [applicationDocumentsDir stringByAppendingPathComponent:@"photo.jpg"];
        NSString *storePathDictionary = [applicationDocumentsDir stringByAppendingPathComponent:@"dictionary.txt"];
        
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:storePathDictionary] &&
            [[NSDictionary dictionaryWithContentsOfFile:storePathDictionary] isEqualToDictionary:self.photo]){
                NSData *picture = [NSData dataWithContentsOfFile:storePathPicture];
                [self showImageFromCache:picture];
                //NSLog(@"cached");
        }else{
            
            //NSLog(@"loaded from Net");
            self.imageURL = [FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatLarge];
            dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
            dispatch_async(downloadQueue, ^{
                NSData *data = [NSData dataWithContentsOfURL:self.imageURL];
                [data writeToFile:storePathPicture atomically:NO];
                [self.photo writeToFile:storePathDictionary atomically:NO];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showImageFromCache:data];
                });
            });
            
        }
    }
}


-(void) showImageFromCache:(NSData*) pic{
    
    UIImage *image = [UIImage imageWithData:pic];
    self.imageView.image = image;
    [self.activityIndi stopAnimating];
    [self.navigationItem setRightBarButtonItem:nil];
    
    NSString *title = [self.photo objectForKey:@"title"];
    
    NSString *description = [self.photo valueForKeyPath:@"description._content"];
    if ([title isEqualToString:@""]) {
        title =  [NSMutableString stringWithString: description];
        if ([title isEqualToString:@""]) title=@"Unknown";
    }
    self.titleLabel.text=title;
    
    self.scrollViewWithImage.delegate = self;
    
    self.scrollViewWithImage.contentSize = self.imageView.image.size;
    self.imageView.frame =
    CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.activityIndi stopAnimating];
    [self updateImage];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.photoDatabase = [HelperClass database];
     
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

-(void) addPhotoToDB {
    [self.favButton setTitle:@"Unvisit"];
    
    NSArray *frc = [self searchDbById];
    //create Photo
    Photo *photoToDB = nil;   
    
    if (!frc || ([frc count] > 1)) {
        // handle error
    } else if ([frc count] == 0) {
        
        photoToDB = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:self.photoDatabase.managedObjectContext];
        
        photoToDB.uniqueId = [self.photo valueForKey:@"id"];
        NSString *title = [HelperClass getValidTitleForPhoto:self.photo];
        photoToDB.title = title;
        photoToDB.subtitle = [self.photo valueForKeyPath:@"description._content"];
        photoToDB.farm = [self.photo valueForKey:@"farm"];
        photoToDB.server = [self.photo valueForKey:@"server"];
        photoToDB.secret = [self.photo valueForKey:@"secret"];
        photoToDB.url = [[FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatLarge] absoluteString];       
    }
    
    //Enter location into Database
    NSFetchRequest *placeRequest = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
    
    placeRequest.predicate = [NSPredicate predicateWithFormat:@"location = %@",
                              [self.photo valueForKey:@"derived_place"]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"location" ascending:YES];
    placeRequest.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    Place *place =nil;
    
    NSArray *locations = [self.photoDatabase.managedObjectContext executeFetchRequest:placeRequest error:nil];
    
    if (!locations || ([locations count] > 1)) {
        // handle error
    } else if ([locations count] == 0) {
        place = [NSEntityDescription insertNewObjectForEntityForName:@"Place"
                                              inManagedObjectContext:self.photoDatabase.managedObjectContext];
        place.location = [self.photo valueForKey:@"derived_place"];
        place.timeAdded = [NSString stringWithFormat:@"%g",CACurrentMediaTime()];
        photoToDB.location=place;       
        
    }else {
        photoToDB.location=[locations lastObject];
    }
    
    //Enter tags into Database
    
    Tag *t=nil;
    NSMutableSet *s = [NSMutableSet set];
    NSString *tags = [self.photo valueForKey:@"tags"];
    //NSLog(@"%@",tags);
    NSArray *tagSplit = [tags componentsSeparatedByString:@" "];
    for (NSString *tag in tagSplit) {
        if ([tag rangeOfString:@":"].location == NSNotFound && ![tag isEqualToString:@""]){
            NSFetchRequest *tagRequest = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
            tagRequest.predicate = [NSPredicate predicateWithFormat:@"name = %@", tag];
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
            tagRequest.sortDescriptors = [NSArray arrayWithObject:sort];
            
            NSArray *tagArray = [self.photoDatabase.managedObjectContext executeFetchRequest:tagRequest error:nil];
            if ([tagArray count]==1) {
                t = [tagArray lastObject];
                int counter = [t.count intValue];
                counter++;
                t.count = [NSString stringWithFormat:@"%d",counter];
                [s addObject:t];
            }else{
                t = [NSEntityDescription insertNewObjectForEntityForName:@"Tag"
                                                  inManagedObjectContext:self.photoDatabase.managedObjectContext];
                t.name =tag;
                t.count = @"1";
                [s addObject:t];
            }
        }
    }
    photoToDB.tags = s;    
    //save Database on Disk
    [self.photoDatabase saveToURL:self.photoDatabase.fileURL
                 forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
}

//Delete the photo and update the tags Place
-(void) deletePhotoFromDB {
    //Delete the photo and update the tags Place
    [self.favButton setTitle:@"Visit"];
    NSArray *frc = [self searchDbById];
    if ([frc count]==1) {
        Photo *p = [frc lastObject];
        
        NSMutableSet *tagsSet = [NSMutableSet set];
        for (Tag *tagToDel in p.tags) {
            if ([tagToDel.count isEqualToString:@"1"]){
                [self.photoDatabase.managedObjectContext deleteObject:tagToDel];
            }else{
                int n = [tagToDel.count intValue];
                n--;
                tagToDel.count = [NSString stringWithFormat:@"%d",n];
                [tagsSet addObject:tagToDel];
            }
        }
        p.tags=tagsSet;
        
        if ([p.location.photos count]==1) [self.photoDatabase.managedObjectContext deleteObject:p.location];
        [self.photoDatabase.managedObjectContext deleteObject:[frc lastObject]];
    }
    
}
//gets called ehen the visit Button is clicked
- (IBAction)addFaves:(id)sender {
    if (self.photo) {
        if ([self.favButton.title isEqualToString:@"Visit"]){
            self.vacations = [HelperClass loadVacations];
            CGRect frame = CGRectMake(0, 0,
                                      250,
                                      300);
            UITableView *tableView = [[UITableView alloc]
                                      initWithFrame:frame
                                      style:UITableViewStylePlain];
            tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            tableView.delegate = self;
            tableView.dataSource = self;
            [tableView reloadData];
            UIViewController* content = [[UIViewController alloc] init];
            content.view = tableView;
            
            if (self.splitViewController) {
                self.favButton.enabled = NO;
                CGSize size = CGSizeMake(250,
                                         300);
                content.contentSizeForViewInPopover = size;
                UIPopoverController* popover = [[UIPopoverController alloc]
                                                initWithContentViewController:content];
                popover.delegate = self;
                self.pc = popover;
                [self.pc presentPopoverFromBarButtonItem:sender
                                               permittedArrowDirections:UIPopoverArrowDirectionAny
                                                               animated:YES];
            }
           
            
        }else if ([self.favButton.title isEqualToString:@"Unvisit"]){
            [self deletePhotoFromDB];
        }        
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return [self.vacations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Visit Vacations Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    cell.textLabel.text = [self.vacations objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *vacation = [self.vacations objectAtIndex:indexPath.row];
    self.photoDatabase = [HelperClass database:vacation];
    [self addPhotoToDB];
    [self.pc dismissPopoverAnimated:YES];
    self.favButton.enabled = YES;
}

#pragma mark - Popover View delegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.favButton.enabled = YES;
}


@end
