//
//  Contact.h
//  Pods
//
//  Created by Luuk harmeling on 07/04/15.
//
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
