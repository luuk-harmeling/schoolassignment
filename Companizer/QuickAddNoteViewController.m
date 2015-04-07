//
//  QuickAddNoteViewController.m
//  Companizer
//
//  Created by Luuk harmeling on 01/04/15.
//  Copyright (c) 2015 Luuk harmeling & Hugo Olthof. All rights reserved.
//

#import "QuickAddNoteViewController.h"

@interface QuickAddNoteViewController ()

@property NSString *fieldContents;

@end

@implementation QuickAddNoteViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self becomeFirstResponder];
        
    self.navigationController.navigationBar.translucent = NO;
        
        
        
    NSLog(@"The contetnts : %@", self.fieldContents);
    // Do any additional setup after loading the view.
    }
    
    - (void)didReceiveMemoryWarning{
        [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}
    
- (IBAction)saveButtonPressed:(id)sender
{
    self.fieldContents = [self getHTML];
    NSLog(@"contents: %@", self.fieldContents);
}

@end
