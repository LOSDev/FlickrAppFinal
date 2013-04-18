//
//  StaticTableViewController.h
//  FlickerApp
//
//  Created by Rincewind on 24.01.13.
//  Copyright (c) 2013 Rincewind. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StaticTableViewController : UITableViewController
@property NSString * databaseName;
@property UIManagedDocument *database;
@end
