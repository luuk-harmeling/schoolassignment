//
//  Company.h
//  Pods
//
//  Created by Luuk harmeling on 07/04/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contact;

@interface Company : NSManagedObject

@property (nonatomic, retain) NSString * adress;
@property (nonatomic, retain) NSData * logo;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSSet *contacts;
@end

@interface Company (CoreDataGeneratedAccessors)

- (void)addContactsObject:(Contact *)value;
- (void)removeContactsObject:(Contact *)value;
- (void)addContacts:(NSSet *)values;
- (void)removeContacts:(NSSet *)values;

@end
