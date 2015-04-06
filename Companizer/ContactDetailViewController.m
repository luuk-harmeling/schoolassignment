//
//  ContactDetailViewController.m
//  Companizer
//
//  Created by Luuk harmeling on 01/04/15.
//  Copyright (c) 2015 Luuk harmeling & Hugo Olthof. All rights reserved.
//

#import "ContactDetailViewController.h"
#import "Company.h"

@interface ContactDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *contactNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *contactNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *contactCompanyLabel;


@property (weak, nonatomic) NSString *selectedContactName;
@property (weak, nonatomic) NSString *selectedContactPhoneNumber;

@end

@implementation ContactDetailViewController


// Managing the selected object
- (void)setContactForDetailPage:(Contact *)newDetailItem
{
    
    if (_selectedContact != newDetailItem) {
        _selectedContact = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{

    // Update the user interface for the detail item.
    if (self.selectedContact)
    {
        self.selectedContactName = self.selectedContact.name;
        self.selectedContactPhoneNumber = self.selectedContact.phoneNumber;
        
    }
    
    
}

- (void)updateUI
{
    self.contactNameLabel.text = self.selectedContact.name;
    self.contactNumberLabel.text = self.selectedContact.phoneNumber;
    self.contactCompanyLabel.text = self.selectedContact.company.name;
    self.contactNumberLabel.editable = NO;
    self.contactNumberLabel.dataDetectorTypes = UIDataDetectorTypeAll;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self updateUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
