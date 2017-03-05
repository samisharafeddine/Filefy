//
//  TWRDownloadManager.h
//  DownloadManager
//
//  Created by Michelangelo Chasseur on 25/07/14.
//  Copyright (c) 2014 Touchware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGBase.h>

@interface TWRDownloadManager : NSObject

@property (nonatomic, strong) void(^backgroundTransferCompletionHandler)();
@property (strong, nonatomic) NSMutableDictionary *downloads;

+ (instancetype)sharedManager;

- (void)downloadFileForURL:(NSString *)urlString
                  withName:(NSString *)fileName
             progressBlock:(void(^)(CGFloat progress))progressBlock
             remainingTime:(void(^)(NSUInteger seconds))remainingTimeBlock
           completionBlock:(void(^)(BOOL completed))completionBlock
      enableBackgroundMode:(BOOL)backgroundMode;

- (void)cancelAllDownloads;
- (void)cancelDownloadForUrl:(NSString *)fileIdentifier;

- (void)cleanDirectoryNamed:(NSString *)directory;

- (BOOL)isFileDownloadingForUrl:(NSString *)fileIdentifier;
- (BOOL)isFileDownloadingForUrl:(NSString *)url withProgressBlock:(void(^)(CGFloat progress))block;
- (BOOL)isFileDownloadingForUrl:(NSString *)url withProgressBlock:(void(^)(CGFloat progress))block completionBlock:(void(^)(BOOL completed))completionBlock;

- (NSString *)localPathForFile:(NSString *)fileIdentifier;
- (NSString *)localPathForFile:(NSString *)fileIdentifier inDirectory:(NSString *)directoryName;

- (BOOL)fileExistsForUrl:(NSString *)urlString;
- (BOOL)fileExistsForUrl:(NSString *)urlString inDirectory:(NSString *)directoryName;
- (BOOL)fileExistsWithName:(NSString *)fileName;
- (BOOL)fileExistsWithName:(NSString *)fileName inDirectory:(NSString *)directoryName;

- (BOOL)deleteFileForUrl:(NSString *)urlString;
- (BOOL)deleteFileForUrl:(NSString *)urlString inDirectory:(NSString *)directoryName;
- (BOOL)deleteFileWithName:(NSString *)fileName;
- (BOOL)deleteFileWithName:(NSString *)fileName inDirectory:(NSString *)directoryName;

/**
 *  This method helps checking which downloads are currently ongoing.
 *
 *  @return an NSArray of NSString with the URLs of the currently downloading files.
 */
- (NSArray *)currentDownloads;

@end
