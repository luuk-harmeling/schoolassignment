//
//  AddNoteViewController.h
//  Companizer
//
//  Created by Luuk harmeling on 01/04/15.
//  Copyright (c) 2015 Luuk harmeling & Hugo Olthof. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSSRichTextEditor.h"
#import "Contact.h"

@interface AddNoteViewController : ZSSRichTextEditor <UIAlertViewDelegate>

@property (strong, nonatomic) Contact  *contactForNote;


@end
