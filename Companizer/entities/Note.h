//
//  Note.h
//  Pods
//
//  Created by Luuk harmeling on 07/04/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contact;

@interface Note : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * note_type;
@property (nonatomic, retain) Contact *contact;

@end
