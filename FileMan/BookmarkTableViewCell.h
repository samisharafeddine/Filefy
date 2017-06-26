//
//  BookmarkTableViewCell.h
//  FileMan
//
//  Created by Sami Sharaf on 1/17/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookmarkTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *title;

@end
