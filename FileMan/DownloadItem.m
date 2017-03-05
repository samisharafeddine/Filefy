//
//  DownloadItem.m
//  FileMan
//
//  Created by Sami Sharaf on 3/1/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import "DownloadItem.h"

@implementation DownloadItem

-(id)initWithFileTitle:(NSString *)title andDownloadSource:(NSURL *)source {
    
    if (self == [super init]) {
        
        self.fileTitle = title;
        self.downloadSource = source;
        self.downloadProgress = 0.0;
        self.isDownloading = NO;
        self.didFail = YES;
        self.downloadComplete = NO;
        self.taskIdentifier = -1;
        
    }
    
    return self;
    
}

@end
