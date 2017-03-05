//
//  DownloadManager.h
//  FileMan
//
//  Created by Sami Sharaf on 3/1/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadManager : NSObject <NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) NSMutableArray *currentDownloads;

@property (nonatomic, strong) NSURL *documentsDir;

+(instancetype)sharedManager;

-(void)downloadFileAtURL:(NSURL *)url withName:(NSString *)name;

@end
