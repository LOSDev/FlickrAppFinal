//
//  FavPlacesViewController.h
//  FlickerApp
//
//  Created by Rincewind on 25.01.13.
//  Copyright (c) 2013 Rincewind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"
#import "CoreDataTableViewController.h"

@interface FavPlacesViewController : CoreDataTableViewController
@property Place *place;
@property (nonatomic) UIManagedDocument *database;
@end
