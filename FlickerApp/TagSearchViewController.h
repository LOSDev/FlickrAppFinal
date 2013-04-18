//
//  TagSearchViewController.h
//  FlickerApp
//
//  Created by Rincewind on 25.01.13.
//  Copyright (c) 2013 Rincewind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@interface TagSearchViewController : CoreDataTableViewController <UISearchBarDelegate, UISearchDisplayDelegate>

@property NSString *databaseName;


@end
