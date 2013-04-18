//
//  TagPictureViewController.h
//  FlickerApp
//
//  Created by Rincewind on 25.01.13.
//  Copyright (c) 2013 Rincewind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "Tag.h"

@interface TagPictureViewController : CoreDataTableViewController

@property UIManagedDocument *database;
@property Tag *tag;
@end
