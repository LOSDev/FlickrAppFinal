//
//  GetValidTitleForPhoto.m
//  FlickerApp
//
//  Created by Rincewind on 26.01.13.
//  Copyright (c) 2013 Rincewind. All rights reserved.
//

#import "HelperClass.h"

@implementation HelperClass

@synthesize photodatabase = _photodatabase;


+(NSString *) getValidTitleForPhoto: (NSDictionary *)photo{
    
    NSString *title = [photo objectForKey:@"title"];
    
    NSString *description = [photo valueForKeyPath:@"description._content"];
    if ([title isEqualToString:@""]) {
        title =  [NSMutableString stringWithString: description];
        if ([title isEqualToString:@""]) title=@"Unknown";
    }
    return title;
}




-(id)init {
    if ( self = [super init] ) {
    }
    return self;
}

+ (UIManagedDocument* ) database {
    static UIManagedDocument* db = nil;
    if (!db) {  // for demo purposes, we'll create a default database if none is set
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"My Vacation"];
        // url is now "<Documents Directory>/My Vacation"
        db = [[UIManagedDocument alloc] initWithFileURL:url]; // setter will create this for us on disk
    }
    return db;

}

+ (UIManagedDocument* ) database:(NSString *) filename {
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:filename];
    static UIManagedDocument* db2 = nil;
    if (!db2 || ![url isEqual:db2.fileURL]) {  // for demo purposes, we'll create a default database if none is set
        db2=nil;
        // url is now "<Documents Directory>/My Vacation"
        db2 = [[UIManagedDocument alloc] initWithFileURL:url]; // setter will create this for us on disk
    }
        return db2;
    
}


- (void)openDocument
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.photodatabase.fileURL path]]) {
        // does not exist on disk, so create it
        [self.photodatabase saveToURL:self.photodatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            //[self setupFetchedResultsController];
            //[self fetchFlickrDataIntoDocument:self.photoDatabase];
            
        }];
    } else if (self.photodatabase.documentState == UIDocumentStateClosed) {
        // exists on disk, but we need to open it
        [self.photodatabase openWithCompletionHandler:^(BOOL success) {
            //[self setupFetchedResultsController];
        }];
    } else if (self.photodatabase.documentState == UIDocumentStateNormal) {
        // already open and ready to use
        //[self setupFetchedResultsController];
    }
}

// 2. Make the photoDatabase's setter start using it

- (void)setPhotodatabase:(UIManagedDocument *)photoDatabase
{
    if (_photodatabase != photoDatabase) {
        _photodatabase = photoDatabase;
        [self openDocument];
    }
}

+(NSArray *) loadVacations{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSArray *temp = [[NSFileManager defaultManager]
                        contentsOfDirectoryAtPath:documentsPath error:nil];
    NSMutableArray *result = [NSMutableArray array];
    BOOL isDir;
    for (NSString *file in temp) {
        
        if([[NSFileManager defaultManager] fileExistsAtPath:[[paths objectAtIndex:0]
                                                             stringByAppendingPathComponent:file]
                                                isDirectory:&isDir] && isDir){
            
            [result addObject:file];
        }
    }
    return result;
    
}

@end