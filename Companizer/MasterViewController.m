//
//  MasterViewController.m
//  Companizer
//
//  Created by Luuk harmeling on 30/03/15.
//  Copyright (c) 2015 Luuk harmeling & Hugo Olthof. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <GAI.h>
#import <GAIFields.h>
#import <GAIDictionaryBuilder.h>

@interface MasterViewController ()

@end

@implementation MasterViewController


/*
 Default functions
 */
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"MasterViewController"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)awakeFromNib {
    [super awakeFromNib];}
- (void)viewDidLoad
{
    [super viewDidLoad];


}

#pragma mark - IBActions

/* 
 Outlet for the addcompany button
 */
- (IBAction)addCompanyButtonTouched:(id)sender{}

#pragma mark - Segues

/*
 Segue preparation for a click on a cell
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([[segue identifier] isEqualToString:@"showDetail"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Company *companyfordetails = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [[segue destinationViewController] setDetailItem:companyfordetails];
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
    
    CALayer *cellImageLayer = cell.imageView.layer;
    [cellImageLayer setCornerRadius:9];
    [cellImageLayer setMasksToBounds:YES];
    
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
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    
    
    Company *company = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSData *temp = company.logo;
    UIImage *tempImage = [UIImage imageWithData:temp];
    
    cell.textLabel.text = [[company valueForKey:@"name"] description];

    
    UIImage *thumbnailImage= [self rescaleImage:tempImage];
    
    cell.imageView.image = thumbnailImage;


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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Company" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error])
    {
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


#pragma mark - Utility methods

/*
 This function (that is called in the configureCell function of the tableView function) will crop any image to a certain format
 */
- (UIImage *)rescaleImage:(UIImage *)image{
    CGSize size;
    size.width = 42;
    size.height = 42;
    
    UIGraphicsBeginImageContext(size);
    
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSLog(@"rescaling done");
    
    return newImage;
}

/*
 this auto-generated stub will fire when too much memory is being used by the application
 */
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
