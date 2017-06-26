//
//  DownloadsTableViewController.h
//  FileMan
//
//  Created by Sami Sharaf on 3/5/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadsTableViewController : UITableViewController {
    
    NSArray *currentDownloads;
    NSArray *completedDownloadsNames;
    NSArray *completedDownloadsURLs;
    NSArray *completedDownloadsStatuses;
    NSArray *content;
    
}

@end
