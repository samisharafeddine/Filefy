//
//  EditPropsTableViewController.h
//  FileMan
//
//  Created by Sami Sharaf on 2/9/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditPropsTableViewController : UITableViewController {
    
    BOOL editMode;
    
}

@property NSString *path;
@property NSString *fileTitle;

@end
