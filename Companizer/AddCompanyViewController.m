//
//  AddCompanyViewController.m
//  Companizer
//
//  Created by Luuk harmeling on 30/03/15.
//  Copyright (c) 2015 Luuk harmeling & Hugo Olthof. All rights reserved.
//

#import "AddCompanyViewController.h"
#import "AppDelegate.h"
#import "Company.h"
#import <GAI.h>
#import <GAIFields.h>
#import <GAIDictionaryBuilder.h>

@interface AddCompanyViewController ()

@property (weak, nonatomic) IBOutlet UITextField *companyName;
@property (weak, nonatomic) IBOutlet UITextField *companyAdress;
@property (weak, nonatomic) IBOutlet UITextField *companyPhone;
@property (weak, nonatomic) IBOutlet UIButton *saveCompanyButton;
@property (weak, nonatomic) IBOutlet UIImageView *logoRepresentation;



@property NSManagedObjectContext                 *context;
@property NSData                                *companyLogo;


@end

@implementation AddCompanyViewController


/*
 Default functions
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
    
    
    // get the context from the AppDelegate
    self.context = [[[UIApplication sharedApplication] delegate] performSelector:@selector(getManagedContext)];
    

    
    // initialize the textfields
    [self clearFields];
    
    
    //For keyboard dismissal when the user taps outside the text field
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyBoard)];
    [self.view addGestureRecognizer:tap];
}

#pragma mark - Button Handling

/* GENERAL
 These functions handle what has to happen when one of the following buttons in the view are clicked:
    -clear button touch
    -save button touch
    -add logo button touched
 */

- (IBAction)clearButtonTouched:(id)sender{
    [self clearFields];
}
- (IBAction)saveButtonTouched:(id)sender{
    if (![self checkForDuplicates:self.companyName.text])
    {
        [self addCompany];

    }
    else
    {
        UIAlertView *completionAlert = [[UIAlertView alloc] initWithTitle:@"Fout!" message:@"het bedrijf is reeds al toegevoed!" delegate:self cancelButtonTitle:@"terugkeren" otherButtonTitles:nil, nil];
        [completionAlert show];
    }
    
    
}

/*
 This button will handle intiate the person picking from the address book (iOS standart impemented framework (Addressbook.framework)
 */
- (IBAction)addLogoButtonClicked:(id)sender{
    @try
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        // this will prompt the device library (camera can be chosen aswell if wished)
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = self;
        
        [self presentViewController:picker animated:YES completion:nil];
    }
    @catch (NSException *exception)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Camera" message:@"The camera is not available"
                                                       delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}


#pragma mark - Core data functions

/*
 this function (with minimal validation) will add a company to the core data database.
    -Validation checks:
        - check if all fields are filled
        - check if the company does not already exists in core data
 */
- (void) addCompany{
    if([self.companyName.text length] != 0 && [self.companyAdress.text length] != 0 && [self.companyPhone.text length] != 0)
    {
        Company *company = [NSEntityDescription insertNewObjectForEntityForName:@"Company" inManagedObjectContext:self.context];
        company.name            = self.companyName.text;
        company.adress          = self.companyAdress.text;
        company.phoneNumber     = self.companyPhone.text;
        
        // if the company logo has been set, it will be saved to core data now
        if (self.companyLogo != nil)
        {
            company.logo = self.companyLogo;
        }
        
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
            UIAlertView *completionAlert = [[UIAlertView alloc] initWithTitle:@"Succes!" message:@"het bedrijf is toegevoegd!" delegate:self cancelButtonTitle:@"terugkeren" otherButtonTitles:nil, nil];
            [completionAlert show];
            
            // This code will automatically redirect to the last controller if wished.
            //[self.navigationController popToRootViewControllerAnimated:YES];
        }
        
    }
    else
    {
        UIAlertView *completionAlert = [[UIAlertView alloc] initWithTitle:@"Fout!" message:@"Niet alle velden zijn ingevuld!" delegate:self cancelButtonTitle:@"terugkeren" otherButtonTitles:nil, nil];
        [completionAlert show];
    }
}

#pragma mark - Utilities

/*
 This function will set an image to the private image variable if its picked by the user
 */
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.logoRepresentation.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    self.companyLogo = UIImagePNGRepresentation(self.logoRepresentation.image);
    
    if (self.companyLogo != nil)
    {
        NSLog(@"hij is niet leeg");
    }
    else
    {
        NSLog(@"hij is wel leeg");
    }
    
}

/*
 Validation helper method for the addCompany function
 */
-(BOOL)checkForDuplicates:(NSString *)companyNameToCheck{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Company"
                                              inManagedObjectContext:self.context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                   ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    [request setSortDescriptors:sortDescriptors];

    
    NSError *Fetcherror;
    NSMutableArray *mutableFetchResults = [[self.context
                                            executeFetchRequest:request error:&Fetcherror] mutableCopy];
    
    
    
    if ([[mutableFetchResults valueForKey:@"name"] containsObject:companyNameToCheck]) {
        //notify duplicates
        NSLog(@"Duplicate found");
        return true;
    }
    
    NSLog(@"No duplicates found");
    return false;
    
}

/*
 Helper function for the clear fields button
 */
- (void)clearFields{
    self.companyName.text   = @"";
    self.companyAdress.text = @"";
    self.companyPhone.text  = @"";

}

/*
 Default method stub for memory warnings
 */
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 This will dismiss the keyboard when clicked outside a textfield
 */
- (void)dismissKeyBoard{
    [self.companyName resignFirstResponder];
    [self.companyAdress resignFirstResponder];
    [self.companyPhone resignFirstResponder];
}


@end
