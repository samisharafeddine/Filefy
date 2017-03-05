//
//  DownloadsTableViewCell.h
//  FileMan
//
//  Created by Sami Sharaf on 3/5/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TWRDownloadObject.h"

@interface DownloadsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UILabel *info;
@property (weak, nonatomic) IBOutlet UILabel *percentage;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressHeight;

@property (strong, nonatomic) TWRDownloadProgressBlock progressBlock;
@property (strong, nonatomic) TWRDownloadCompletionBlock completionBlock;

@end
