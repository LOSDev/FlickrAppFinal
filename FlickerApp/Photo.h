//
//  Photo.h
//  FlickerApp
//
//  Created by Rincewind on 27.01.13.
//  Copyright (c) 2013 Rincewind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Place;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSNumber * farm;
@property (nonatomic, retain) NSString * secret;
@property (nonatomic, retain) NSString * server;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * uniqueId;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) Place *location;
@property (nonatomic, retain) NSSet *tags;
@end

@interface Photo (CoreDataGeneratedAccessors)

- (void)addTagsObject:(NSManagedObject *)value;
- (void)removeTagsObject:(NSManagedObject *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
