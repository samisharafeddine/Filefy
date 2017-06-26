//
//  EditMIMETableViewController.h
//  FileMan
//
//  Created by Sami Sharaf on 3/6/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditMIMETableViewController : UITableViewController

@property NSString *mimeType;
@property int index;
@property (weak, nonatomic) IBOutlet UITextField *mime;

@end
