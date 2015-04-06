//
//  DetailViewController.h
//  Companizer
//
//  Created by Luuk harmeling on 30/03/15.
//  Copyright (c) 2015 Luuk harmeling & Hugo Olthof. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import <CoreData/CoreData.h>
#import "Company.h"


@interface DetailViewController : UIViewController <ABPeoplePickerNavigationControllerDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) Company *detailItem;




@end

