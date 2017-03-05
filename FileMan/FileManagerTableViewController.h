//
//  FileManagerTableViewController.h
//  FileMan
//
//  Created by Sami Sharaf on 2/5/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MWPhotoBrowser.h"
#import "SSZipArchive.h"

@interface FileManagerTableViewController : UITableViewController <UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate, UIScrollViewDelegate, MWPhotoBrowserDelegate> {
    
    CGFloat scrollOffset;
    BOOL isBarHidden;
    BOOL isEditing;
    NSIndexPath *indexPathForAccessoryButton;
    NSString *passedFilePath;
    
}

@property NSString *path;
@property NSArray *files;
@property NSArray *searchResults;
@property NSMutableArray *editingArray;
@property NSString *folderName;
@property NSMutableArray *musicFiles; // As FilePaths
@property NSMutableArray *musicIndex;
@property NSMutableArray *photoFiles; // As URLs
@property NSMutableArray *photoIndex;

@end
