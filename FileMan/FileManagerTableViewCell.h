//
//  FileManagerTableViewCell.h
//  FileMan
//
//  Created by Sami Sharaf on 2/5/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XFile.h"

@interface FileManagerTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *displayImage;
@property (weak, nonatomic) IBOutlet UILabel *displayName;
@property (weak, nonatomic) IBOutlet UILabel *displaySize;

@end
