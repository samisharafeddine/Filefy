//
//  DownloadsTableViewCell.h
//  FileMan
//
//  Created by Sami Sharaf on 3/1/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadItem.h"

@interface DownloadsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;

@end
