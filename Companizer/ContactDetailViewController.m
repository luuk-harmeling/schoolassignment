//
//  ContactDetailViewController.m
//  Companizer
//
//  Created by Luuk harmeling on 01/04/15.
//  Copyright (c) 2015 Luuk harmeling & Hugo Olthof. All rights reserved.
//

#import "ContactDetailViewController.h"
#import "EditNoteViewController.h"
#import "AddNoteViewController.h"
#import "Note.h"
#import "Company.h"
#import "AppDelegate.h"
#import <GAI.h>
#import <GAIFields.h>
#import <GAIDictionaryBuilder.h>

@interface ContactDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel        *contactNameLabel;
@property (weak, nonatomic) IBOutlet UITextView     *contactNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel        *contactCompanyLabel;
@property (weak, nonatomic) IBOutlet UITableView    *tableView;


@property (weak, nonatomic) NSString                *selectedContactName;
@property (weak, nonatomic) NSString                *selectedContactPhoneNumber;
@property NSManagedObjectContext                    *context;


@end

@implementation ContactDetailViewController


/*
 Default functions
 */
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"ContactDetailViewController"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
 
    
    self.context = [[[UIApplication sharedApplication] delegate] performSelector:@selector(getManagedContext)];
    
    [self updateUI];
}

/*
 This function will put the contact (given from the parent segue)
 */
- (void)setContactForDetailPage:(Contact *)newDetailItem{
    
    if (_selectedContact != newDetailItem)
    {
        _selectedContact = newDetailItem;
        [self configureView];
    }
}

/*
 helper method for the setContactForDetailPage
 */
- (void)configureView{
    if (self.selectedContact)
    {
        [self updateUI];
    }
}

/*
 This function will update the details for the contact (if instantiated)
 */
- (void)updateUI{
    self.contactNameLabel.text = self.selectedContact.name;
    self.contactNumberLabel.text = self.selectedContact.phoneNumber;
    self.contactCompanyLabel.text = self.selectedContact.company.name;
    self.contactNumberLabel.editable = NO;
    self.contactNumberLabel.dataDetectorTypes = UIDataDetectorTypeAll;

}


#pragma mark - Segues

/*
 The handling of multiple segues here
    - AddNoteSegue will prepare for adding a note
    - EditMessageSegue will prepare for editing a note
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"AddNoteSegue"])
    {
        // Get reference to the destination view controller
         AddNoteViewController *anvc = [segue destinationViewController];
        
        anvc.contactForNote = self.selectedContact;
    }
    else if ([[segue identifier] isEqualToString: @"editMessageSegue"])
    {
        // Get reference to the destination view controller
        EditNoteViewController *envc = [segue destinationViewController];
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        //Company *companyfordetails = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        Note *selectedNote = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        
        // pass an unique piece of the message so it can be fetched in the destinationcontroller & edited and saved.
        envc.toBeEditedNote = selectedNote;
    }
}


#pragma mark - Table View


/*
 The Delegate & Datasource methods for the tableview (this tableview is for displaying the various companies
 */
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
    Note *object = [self.fetchedResultsController objectAtIndexPath:indexPath];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    
    
    cell.textLabel.text         = object.note_type;
    cell.detailTextLabel.text   = [NSString stringWithFormat:@"Contact: %@ op: %@", object.contact.name, [dateFormatter stringFromDate:object.date]];

}

#pragma mark - Fetched results controller


/*
 The NSFetchedResultsController handles the link between Core Data and the UITableView
 On a change in the Core Data, this controller wil automatically change the content of the table to match the change
 */
- (NSFetchedResultsController *)fetchedResultsController{

    if (_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    //Predicate so that only the contacts for the selected company are shown
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contact.name == %@", self.contactNameLabel.text];
    fetchRequest.predicate = predicate;
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
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

/*
 this auto-generated stub will fire when too much memory is being used by the application
 */
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






@end
