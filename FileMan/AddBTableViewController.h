//
//  AddBTableViewController.h
//  FileMan
//
//  Created by Sami Sharaf on 1/18/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddBTableViewController : UITableViewController <UITextFieldDelegate> {
    
    NSString *url;
    NSMutableArray *titles;
    NSMutableArray *urls;
    
}

@end
