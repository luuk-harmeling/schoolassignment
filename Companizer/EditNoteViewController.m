//
//  EditNoteViewController.m
//  Companizer
//
//  Created by Luuk harmeling on 07/04/15.
//  Copyright (c) 2015 Luuk harmeling & Hugo Olthof. All rights reserved.
//

#import "EditNoteViewController.h"
#import "Note.h"
#import "AppDelegate.h"

@interface EditNoteViewController ()

@property NSManagedObjectContext                    *context;
@property NSString                                  *editedContent;
@property NSString                                  *editedNoteType;

@end


@implementation EditNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.context = [[[UIApplication sharedApplication] delegate] performSelector:@selector(getManagedContext)];
    
    [self setHTML:self.toBeEditedNote.content];
    
    
    UIAlertView* message = [[UIAlertView alloc]
                            initWithTitle: @"Choose the note type"
                            message: @"press cancel if the type was correct"
                            delegate: self
                            cancelButtonTitle: @"cancel"
                            otherButtonTitles: @"phonecall log",@"instant message log", @"email log", nil];
    
    [message becomeFirstResponder];
    [message show];
    

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button handling

- (IBAction)saveChangesButtonTouched:(id)sender
{
    self.editedContent = [self getHTML];
    
    NSLog(self.editedContent);
    
    [self updateCurrentRecord:self.editedContent :self.editedNoteType];
}

//TODO
    // fetch the note from core data
    // show it in the textbox
    // make the user edit it
    // prompt the message type

#pragma mark - Utilities

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSString *string = [alertView buttonTitleAtIndex:buttonIndex];
    
    if ([string isEqualToString:@"phonecall log"])
    {
        self.editedNoteType = @"phonecall log";
    }
    else if ([string isEqualToString:@"instant message log"])
    {
        self.editedNoteType = @"instant message log";
    }
    else if ([string isEqualToString:@"email log"])
    {
        self.editedNoteType = @"email log";
    }
    // cancel was pressed and the note_type was not edited
    else if([string isEqualToString:@"return"])
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        self.editedNoteType = self.toBeEditedNote.note_type;
    }
    
}

- (void)updateCurrentRecord:(NSString *)contents :(NSString *)noteType
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"content == %@", self.toBeEditedNote.content];
    request.predicate = predicate;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    
    Note *fetchedNote = [[self.context executeFetchRequest:request error:&error] objectAtIndex:0];
    
    fetchedNote.content = contents;
    fetchedNote.note_type = noteType;
    
    //Save the context
    [self.context save:&error];

    if (error == nil)
    {
        
        UIAlertView* message = [[UIAlertView alloc]
                                initWithTitle: @"Succes!"
                                message: @"The note was edited successfully!"
                                delegate: self
                                cancelButtonTitle: nil
                                otherButtonTitles: @"return", nil];
        
        [message becomeFirstResponder];
        [message show];
    }

    
    
    
}



@end
