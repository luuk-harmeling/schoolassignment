//
//  EditNoteViewController.h
//  Companizer
//
//  Created by Luuk harmeling on 07/04/15.
//  Copyright (c) 2015 Luuk harmeling & Hugo Olthof. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZSSRichTextEditor.h>
#import "Note.h"

@interface EditNoteViewController : ZSSRichTextEditor <UIAlertViewDelegate>

@property (strong, nonatomic)Note *toBeEditedNote;

@end
