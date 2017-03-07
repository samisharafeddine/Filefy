//
//  DownloadsTableViewCell.m
//  FileMan
//
//  Created by Sami Sharaf on 3/5/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import "DownloadsTableViewCell.h"

@implementation DownloadsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (TWRDownloadProgressBlock)progressBlock {
    __weak typeof(self)weakSelf = self;
    return ^void(CGFloat progress){
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            // do something with the progress on the cell!
            
            CGFloat prog = progress * 100;
            
            strongSelf.progress.progress = progress;
            strongSelf.percentage.text = [NSString stringWithFormat:@"%i%%", (int)prog];
            
        });
    };
}

- (TWRDownloadCompletionBlock)completionBlock {
    __weak typeof(self)weakSelf = self;
    return ^void(BOOL completed){
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            // do something
            
            strongSelf.info.text = @"Completed";
            strongSelf.progress.hidden = YES;
            strongSelf.percentage.hidden = YES;
            strongSelf.progressHeight.constant = 0;
            
        });
    };
}

- (TWRDownloadInfoBlock)infoBlock {
    __weak typeof(self)weakSelf = self;
    return ^void(NSString *info){
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            // do something
            
            strongSelf.info.text = info;
            
        });
    };
}

-(void)prepareForReuse {
    [super prepareForReuse];
    
    self.progress.hidden = NO;
    self.progress.progress = 0;
    self.percentage.text = [NSString stringWithFormat:@"0%%"];
    self.percentage.hidden = NO;
    self.progressHeight.constant = 2;
    self.info.text = @"No progress information";
    
}

@end
