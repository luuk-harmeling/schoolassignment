//
//  DetailViewController.m
//  Companizer
//
//  Created by Luuk harmeling on 30/03/15.
//  Copyright (c) 2015 Luuk harmeling & Hugo Olthof. All rights reserved.
//

#import "DetailViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import "Contact.h"
#import "AppDelegate.h"
#import "ContactDetailViewController.h"


@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel        *nameField;
@property (weak, nonatomic) IBOutlet UILabel        *adressField;
@property (weak, nonatomic) IBOutlet UITextView     *phoneNumberField;
@property (weak, nonatomic) IBOutlet UITableView    *tableView;
@property NSManagedObjectContext                    *context;


@property NSMutableArray *contactList;


@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
            
        // Update the view.
        [self configureView];
    }
}
- (void)configureView{
    self.nameField.text             = @"";
    self.adressField.text           = @"";
    self.phoneNumberField.text      = @"";
    
    // Update the user interface for the detail item.
    if (self.detailItem)
    {
        self.nameField.text = [[self.detailItem valueForKey:@"name"] description];
        self.adressField.text  = [[self.detailItem valueForKey:@"adress"] description];
        self.phoneNumberField.text = [[self.detailItem valueForKey:@"phoneNumber"] description];
    
        self.phoneNumberField.editable = NO;
        self.phoneNumberField.dataDetectorTypes = UIDataDetectorTypeAll;
    }
}
- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.context = [[[UIApplication sharedApplication] delegate] performSelector:@selector(getManagedContext)];

    [self configureView];
}

#pragma mark - Contact handling

- (IBAction)addContactButtonTouched:(id)sender{
    ABPeoplePickerNavigationController *picker =
    [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    
    [self presentViewController:picker animated:YES completion: nil];
}
- (void) peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person{

    NSString *firstname = ( __bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *lastname = ( __bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    ABMultiValueRef phoneNumbers = (ABMultiValueRef)ABRecordCopyValue(person, kABPersonPhoneProperty);
    
    NSString *mobilePhoneNumber = @"";
    
    for (int i = 0; i < ABMultiValueGetCount(phoneNumbers); i++)
    {
        if ([(__bridge NSString *)ABMultiValueCopyLabelAtIndex(phoneNumbers, i) isEqualToString:(NSString *)kABPersonPhoneMobileLabel])
        {
            mobilePhoneNumber = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phoneNumbers, i);
        }
    }
    
    NSString *preparedName = [NSString stringWithFormat:@"%@ %@", firstname, lastname];
    
    if (![self checkForDuplicates:preparedName])
    {
        Contact *toAddContact = [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:self.context];
        toAddContact.name = preparedName;
        toAddContact.phoneNumber = mobilePhoneNumber;
        toAddContact.company = self.detailItem;
        
        // Save the context.
        NSError *error = nil;
        if (![self.context save:&error])
        {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.s
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        else
        {
            UIAlertView *completionAlert = [[UIAlertView alloc] initWithTitle:@"Succes!" message:@"Het contact is toegevoegd!" delegate:self cancelButtonTitle:@"terugkeren" otherButtonTitles:nil, nil];
            [completionAlert show];
            
            // This code will automatically redirect to the last controller if wished.
            //[self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
    else
    {
        UIAlertView *completionAlert = [[UIAlertView alloc] initWithTitle:@"Fout!" message:@"Bedrijf heeft dit contact al!" delegate:self cancelButtonTitle:@"terugkeren" otherButtonTitles:nil, nil];
        [completionAlert show];
    }
    
    
}



#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showContactDetailsSegue"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        //Company *companyfordetails = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        Contact *selectedContact = [[self fetchedResultsController] objectAtIndexPath:indexPath];
         ContactDetailViewController *cdvc = [segue destinationViewController];
//        [cdvc setSelectedContact:selectedContact];
        [cdvc setContactForDetailPage:selectedContact];
        
    }
}



#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [[self.fetchedResultsController sections] count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {

        
        [self.context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![self.context save:&error])
        {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[object valueForKey:@"name"] description];
    cell.detailTextLabel.text = [[object valueForKey:@"phoneNumber"] description];   
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController{
    // the company for the predicate
        // the name will be used as the criteria
    NSString *companyName = self.detailItem.name;
    
    
    
    if (_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Contact" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    //Predicate so that only the contacts for the selected company are shown
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"company.name == %@", companyName];
    fetchRequest.predicate = predicate;
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".

    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error])
    {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView beginUpdates];
}
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView endUpdates];
}


#pragma mark - Utilities

-(BOOL)checkForDuplicates:(NSString *)contactNameToCheck
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Contact"
                                              inManagedObjectContext:self.context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    //Predicate so that only the contacts for the selected company are shown
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"company.name == %@", self.nameField.text];
    request.predicate = predicate;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                   ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    [request setSortDescriptors:sortDescriptors];
    
    
    NSError *Fetcherror;
    NSMutableArray *mutableFetchResults = [[self.context
                                            executeFetchRequest:request error:&Fetcherror] mutableCopy];
    
    
    
    if ([[mutableFetchResults valueForKey:@"name"] containsObject:contactNameToCheck]) {
        //notify duplicates
        NSLog(@"Duplicate found");
        return true;
    }
    
    NSLog(@"No duplicates found");
    return false;
    
}


@end
