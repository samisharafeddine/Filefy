//
//  StartDownloadTableViewController.h
//  FileMan
//
//  Created by Sami Sharaf on 3/6/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StartDownloadTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UITextField *fileName;

@property NSString *name;
@property NSString *fileExtension;
@property NSURL *url;

+(instancetype)sharedInstance;

@end
