//
//  TextViewerViewController.h
//  FileMan
//
//  Created by Sami Sharaf on 2/8/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextViewerViewController : UIViewController <UITextViewDelegate> {
    
    NSDictionary *fileContents;
    BOOL editMode;
    
}

@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) NSString *navTitle;

@end
