//
//  AddNoteViewController.m
//  Companizer
//
//  Created by Luuk harmeling on 01/04/15.
//  Copyright (c) 2015 Luuk harmeling & Hugo Olthof. All rights reserved.
//

#import "AddNoteViewController.h"
#import "Note.h"
#import "AppDelegate.h"
#import <GAI.h>
#import <GAIFields.h>
#import <GAIDictionaryBuilder.h>

@interface AddNoteViewController ()

@property NSString                  *fieldContents;
@property NSString                  *contactString;
@property NSString                  *noteType;
@property NSManagedObjectContext    *context;



@end

@implementation AddNoteViewController

/*
 Default methods
 */

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"AddNoteViewController"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    



    
    self.context = [[[UIApplication sharedApplication] delegate] performSelector:@selector(getManagedContext)];
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.contactString = [self createContactString];
    

    [self setHTML:self.contactString];
    self.formatHTML = YES;
    
    if(self.noteType == nil)
    {
        UIAlertView* message = [[UIAlertView alloc]
                                initWithTitle: @"Choose a note type"
                                message: @"for additional information"
                                delegate: self
                                cancelButtonTitle: @"cancel"
                                otherButtonTitles: @"phonecall log",@"instant message log", @"email log", nil];
        
        [message becomeFirstResponder];
        [message show];
        
    }
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Button Handling

/*
 This function handles the saving of the note
 */
- (IBAction)saveButtonPressed:(id)sender
{
    self.fieldContents = [self getHTML];
    [self addNote];
}


#pragma mark - Utilities

/*
 The function that handles the adding of the note
 */
- (void) addNote{
    Note *note = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:self.context];
    note.note_type = self.noteType;
    note.content = self.fieldContents;
    note.contact = self.contactForNote;
    note.date = [NSDate date];
    
    
        // Save the context.
        NSError *error = nil;
        if (![self.context save:&error])
        {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        else
        {
            UIAlertView *completionAlert = [[UIAlertView alloc] initWithTitle:@"Succes!" message:@"The note has been added!" delegate:self cancelButtonTitle:@"back" otherButtonTitles:nil, nil];
            [completionAlert show];
            
            // This code will automatically redirect to the last controller if wished.
            //[self.navigationController popToRootViewControllerAnimated:YES];
        }
    
}

/*
 helper function that converts some data to a for core data fitting format
 */
- (NSString *)createContactString{
    NSString *beforeContactHTML = @"<p><strong> Contact: ";
    NSString *contactInfo = self.contactForNote.name;
    NSString *afterContactHTML = @"</strong></p><br />";
    
    
    NSString *finalizedString = [NSString stringWithFormat:@"%@ %@ %@", beforeContactHTML, contactInfo, afterContactHTML];
    
    return finalizedString;
}

/*
 an alert view.
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    NSString *string = [alertView buttonTitleAtIndex:buttonIndex];
    
    if ([string isEqualToString:@"phonecall log"])
    {
        self.noteType = @"phonecall log";
        NSLog(@"phonecall log");
        
    }
    else if ([string isEqualToString:@"instant message log"])
    {
        self.noteType = @"instant message log";
        NSLog(@"instant message log");
    }
    else if ([string isEqualToString:@"email log"])
    {
        self.noteType = @"email log";
        NSLog(@"email log");
    }
    
}



@end
