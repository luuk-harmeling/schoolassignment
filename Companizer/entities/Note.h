//
//  Note.h
//  Companizer
//
//  Created by Luuk harmeling on 05/04/15.
//  Copyright (c) 2015 Luuk harmeling & Hugo Olthof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contact;

@interface Note : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * note_type;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) Contact *contact;

@end
