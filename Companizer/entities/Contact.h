//
//  Contact.h
//  Companizer
//
//  Created by Luuk harmeling on 05/04/15.
//  Copyright (c) 2015 Luuk harmeling & Hugo Olthof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Company, Note;

@interface Contact : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSData * profileImage;
@property (nonatomic, retain) Company *company;
@property (nonatomic, retain) NSSet *notes;
@end

@interface Contact (CoreDataGeneratedAccessors)

- (void)addNotesObject:(Note *)value;
- (void)removeNotesObject:(Note *)value;
- (void)addNotes:(NSSet *)values;
- (void)removeNotes:(NSSet *)values;

@end
