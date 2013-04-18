//
//  GetValidTitleForPhoto.h
//  FlickerApp
//
//  Created by Rincewind on 26.01.13.
//  Copyright (c) 2013 Rincewind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface HelperClass : NSObject

@property (nonatomic, strong) UIManagedDocument *photodatabase;

+ (NSString *) getValidTitleForPhoto: (NSDictionary *)photo;
+ (UIManagedDocument* ) database;
+ (UIManagedDocument* ) database:(NSString *) filename;
+ (NSArray *) loadVacations;
@end
