//
//  ContactDetailViewController.h
//  Companizer
//
//  Created by Luuk harmeling on 01/04/15.
//  Copyright (c) 2015 Luuk harmeling & Hugo Olthof. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"

@interface ContactDetailViewController : UIViewController <NSFetchedResultsControllerDelegate>


@property (strong, nonatomic) Contact *selectedContact;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;


- (void)setContactForDetailPage:(Contact *)newDetailItem;

@end
