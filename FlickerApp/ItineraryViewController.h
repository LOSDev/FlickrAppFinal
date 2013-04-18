//
//  ItineraryViewController.h
//  FlickerApp
//
//  Created by Rincewind on 24.01.13.
//  Copyright (c) 2013 Rincewind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@interface ItineraryViewController : CoreDataTableViewController

@property NSArray *places;
@property NSString *databaseName;
@end
