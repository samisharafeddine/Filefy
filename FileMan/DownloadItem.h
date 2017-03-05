//
//  DownloadItem.h
//  FileMan
//
//  Created by Sami Sharaf on 3/1/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadItem : NSObject

@property (nonatomic, strong) NSString *fileTitle;

@property (nonatomic, strong) NSURL *downloadSource;

@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

@property (nonatomic, strong) NSData *taskResumeData;

@property (nonatomic) double downloadProgress;

@property (nonatomic) BOOL isDownloading;

@property (nonatomic) BOOL didFail;

@property (nonatomic) BOOL downloadComplete;

@property (nonatomic) unsigned long taskIdentifier;

-(id)initWithFileTitle:(NSString *)title andDownloadSource:(NSURL *)source;

@end
