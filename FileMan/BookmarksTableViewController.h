//
//  BookmarksTableViewController.h
//  FileMan
//
//  Created by Sami Sharaf on 1/17/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookmarksTableViewController : UITableViewController {
    
    NSMutableArray *titles;
    NSMutableArray *urls;
    NSArray *content;
    NSArray *history;
    
}

@end
