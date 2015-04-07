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


- (IBAction)addLogoButtonClicked:(id)sender
{
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

// VERPLAATSEN ALS HET WERKT
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

- (void)clearFields{
    self.companyName.text   = @"";
    self.companyAdress.text = @"";
    self.companyPhone.text  = @"";
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dismissKeyBoard{
    [self.companyName resignFirstResponder];
    [self.companyAdress resignFirstResponder];
    [self.companyPhone resignFirstResponder];
}


@end
