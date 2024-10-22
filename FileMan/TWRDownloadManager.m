//
//  TWRDownloadManager.m
//  DownloadManager
//
//  Created by Michelangelo Chasseur on 25/07/14.
//  Copyright (c) 2014 Touchware. All rights reserved.
//

#import "TWRDownloadManager.h"
#import "TWRDownloadObject.h"
#import <UIKit/UIKit.h>

@interface TWRDownloadManager () <NSURLSessionDelegate, NSURLSessionDownloadDelegate>

@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSURLSession *backgroundSession;

@end

@implementation TWRDownloadManager

+ (instancetype)sharedManager {
    static id sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        // Default session
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        configuration.HTTPMaximumConnectionsPerHost = 2;
        self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];

        // Background session
        NSURLSessionConfiguration *backgroundConfiguration = nil;

        backgroundConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.Sami-Sharaf.Filefy.DownloadSession"];
        backgroundConfiguration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;

        self.backgroundSession = [NSURLSession sessionWithConfiguration:backgroundConfiguration delegate:self delegateQueue:nil];

        self.downloads = [NSMutableDictionary new];
        
        NSLog(@"Manager Initialized");
        
    }
    return self;
}

#pragma mark - Downloading...

- (void)downloadFileForURL:(NSString *)urlString
                  withName:(NSString *)fileName
             progressBlock:(void(^)(CGFloat progress))progressBlock
             remainingTime:(void(^)(NSUInteger seconds))remainingTimeBlock
           completionBlock:(void(^)(BOOL completed))completionBlock
                 infoBlock:(void(^)(NSString *info))infoBlock
      enableBackgroundMode:(BOOL)backgroundMode {
    
    NSURL *url = [NSURL URLWithString:urlString];
    if (!fileName) {
        
        fileName = [urlString lastPathComponent];
        
        NSLog(@"File Name: %@", fileName);
        
    }

    if (![self fileDownloadCompletedForUrl:urlString]) {
        
        NSLog(@"File is downloading!");
        
    } else {
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSURLSessionDownloadTask *downloadTask;
        if (backgroundMode) {
            downloadTask = [self.backgroundSession downloadTaskWithRequest:request];
            NSLog(@"Download using background mode.");
        } else {
            downloadTask = [self.session downloadTaskWithRequest:request];
            NSLog(@"Download without using background mode.");
        }
        TWRDownloadObject *downloadObject = [[TWRDownloadObject alloc] initWithDownloadTask:downloadTask progressBlock:progressBlock remainingTime:remainingTimeBlock completionBlock:completionBlock infoBlock:infoBlock];
        downloadObject.startDate = [NSDate date];
        downloadObject.fileName = fileName;
        [self.downloads addEntriesFromDictionary:@{urlString:downloadObject}];
        [downloadTask resume];
        
    }
}

- (void)cancelDownloadForUrl:(NSString *)fileIdentifier {
    TWRDownloadObject *download = [self.downloads objectForKey:fileIdentifier];
    if (download) {
        [download.downloadTask cancel];
        if (download.completionBlock) {
            download.completionBlock(NO);
        }
    }
    if (self.downloads.count == 0) {
        [self cleanTmpDirectory];

    }
}

- (void)cancelAllDownloads {
    [self.downloads enumerateKeysAndObjectsUsingBlock:^(id key, TWRDownloadObject *download, BOOL *stop) {
        if (download.completionBlock) {
            download.completionBlock(NO);
        }
        [download.downloadTask cancel];
        [self.downloads removeObjectForKey:key];
    }];
    [self cleanTmpDirectory];
}

- (NSArray *)currentDownloads {
    NSMutableArray *currentDownloads = [NSMutableArray new];
    [self.downloads enumerateKeysAndObjectsUsingBlock:^(id key, TWRDownloadObject *download, BOOL *stop) {
        [currentDownloads addObject:download.downloadTask.originalRequest.URL.absoluteString];
    }];
    return currentDownloads;
}

#pragma mark - NSURLSession Delegate

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSString *fileIdentifier = downloadTask.originalRequest.URL.absoluteString;
    TWRDownloadObject *download = [self.downloads objectForKey:fileIdentifier];
    if (download.progressBlock) {
        CGFloat progress = (CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite;
        NSLog(@"Progress: %.2f", progress);
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if(download.progressBlock){
                download.progressBlock(progress); //exception when progressblock is nil
            }
        });
    }
    
    if (download.infoBlock) {
        
        NSTimeInterval interval = [download.startDate timeIntervalSinceNow];
        NSTimeInterval downloadTime = interval * -1;
        
        float speed = (float)totalBytesWritten / (float)downloadTime;
        
        NSString *size = [NSByteCountFormatter stringFromByteCount:(int64_t)speed countStyle:NSByteCountFormatterCountStyleFile];
        
        NSString *speedSize = [NSString stringWithFormat:@"%@/sec", size];
        
        NSString *totalWrite = [NSByteCountFormatter stringFromByteCount:totalBytesWritten countStyle:NSByteCountFormatterCountStyleFile];
        
        NSString *overAllSize = [NSByteCountFormatter stringFromByteCount:totalBytesExpectedToWrite countStyle:NSByteCountFormatterCountStyleFile];
        
        NSString *info = [NSString stringWithFormat:@"%@ of %@ (%@)", totalWrite, overAllSize, speedSize];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if(download.infoBlock){
                download.infoBlock(info);
            }
        });
        
    }

    CGFloat remainingTime = [self remainingTimeForDownload:download bytesTransferred:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    if (download.remainingTimeBlock) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (download.remainingTimeBlock) {
                download.remainingTimeBlock((NSUInteger)remainingTime);
            }
        });
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSLog(@"Download finisehd!");

    if (self.downloads != nil) {
        
        NSString *fileIdentifier = downloadTask.originalRequest.URL.absoluteString;
        TWRDownloadObject *download = [self.downloads objectForKey:fileIdentifier];
        
        BOOL success = YES;
        
        NSString *logMessage;
        
        if ([downloadTask.response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSInteger statusCode = [(NSHTTPURLResponse*)downloadTask.response statusCode];
            if (statusCode >= 400) {
                NSLog(@"ERROR: HTTP status code %@", @(statusCode));
                logMessage = [NSString stringWithFormat:@"Failed - Error: HTTP status code %@", @(statusCode)];
                success = NO;
            }
        }
        
        if (success) {
            
            NSError *error;
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            NSArray *dir = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
            NSURL *docurl = dir[0];
            
            NSString *destinationFilename = download.fileName;
            NSURL *destinationURL = [docurl URLByAppendingPathComponent:destinationFilename];
            NSURL *url;
            
            if ([fileManager fileExistsAtPath:[destinationURL path]]) {
                
                NSString *fileName = destinationFilename.stringByDeletingPathExtension;
                NSString *extension = destinationFilename.pathExtension;
                
                int i = 1;
                
                while (i != 0) {
                    
                    NSString *newFileName = [NSString stringWithFormat:@"%@-%d", fileName, i];
                    NSString *fullName = [NSString stringWithFormat:@"%@.%@", newFileName, extension];
                    
                    url = [docurl URLByAppendingPathComponent:fullName];
                    
                    if ([fileManager fileExistsAtPath:[url path]]) {
                        
                        i++;
                        
                    } else {
                        
                        i = 0;
                        
                    }
                    
                }
                
            } else {
                
                url = destinationURL;
                
            }
            
            [fileManager moveItemAtURL:location toURL:url error:&error];
            
            if (error) {
                
                NSLog(@"ERROR: %@", error.localizedDescription);
                logMessage = [NSString stringWithFormat:@"Failed - Error: %@", error.localizedDescription];
                
            } else {
                
                logMessage = @"Completed";
                
            }
            
        }
        
        if (download.completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                download.completionBlock(success);
            });
        }
        
        // remove object from the download
        [self.downloads removeObjectForKey:fileIdentifier];
        
        NSArray *completedDownloadsNamess = [[NSUserDefaults standardUserDefaults] objectForKey:@"completedDownloadsNames"];
        
        NSArray *completedDownloadsURLss = [[NSUserDefaults standardUserDefaults] objectForKey:@"completedDownloadsURLs"];
        
        NSArray *completedDownloadsStatusess = [[NSUserDefaults standardUserDefaults] objectForKey:@"completedDownloadsStatuses"];
        
        NSMutableArray *completedDownloadsNames = [[NSMutableArray alloc] initWithArray:completedDownloadsNamess];
        
        NSMutableArray *completedDownloadsURLs = [[NSMutableArray alloc] initWithArray:completedDownloadsURLss];
        
        NSMutableArray *completedDownloadsStatuses = [[NSMutableArray alloc] initWithArray:completedDownloadsStatusess];
        
        if (download.fileName != nil || ![download.fileName isEqualToString:@""]) {
            
            [completedDownloadsNames insertObject:download.fileName atIndex:0];
            
        } else {
            
            [completedDownloadsNames insertObject:[NSString stringWithFormat:@"No Name"] atIndex:0];
            
        }
        
        if (fileIdentifier != nil || ![fileIdentifier isEqualToString:@""]) {
            
            [completedDownloadsURLs insertObject:fileIdentifier atIndex:0];
            
        } else {
            
            [completedDownloadsURLs insertObject:[NSString stringWithFormat:@"No URL"] atIndex:0];
            
        }
        
        if (logMessage != nil || ![logMessage isEqualToString:@""]) {
            
            [completedDownloadsStatuses insertObject:logMessage atIndex:0];
            
        } else {
            
            [completedDownloadsStatuses insertObject:[NSString stringWithFormat:@"Unknown Status"] atIndex:0];
            
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:completedDownloadsNames forKey:@"completedDownloadsNames"];
        [[NSUserDefaults standardUserDefaults] setObject:completedDownloadsURLs forKey:@"completedDownloadsURLs"];
        [[NSUserDefaults standardUserDefaults] setObject:completedDownloadsStatuses forKey:@"completedDownloadsStatuses"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Show a local notification when download is over.
            // [todo]
        });
        
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        
        NSLog(@"An Error Occured");
        
        if (self.downloads != nil) {
            
            NSLog(@"ERROR: %@", error);
            
            NSString *logMessage = [NSString stringWithFormat:@"Failed - Error: %@", error.localizedDescription];
            
            NSString *fileIdentifier = task.originalRequest.URL.absoluteString;
            TWRDownloadObject *download = [self.downloads objectForKey:fileIdentifier];
            
            if (download.completionBlock) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    download.completionBlock(NO);
                });
            }
            
            NSArray *completedDownloadsNamess = [[NSUserDefaults standardUserDefaults] objectForKey:@"completedDownloadsNames"];
            
            NSArray *completedDownloadsURLss = [[NSUserDefaults standardUserDefaults] objectForKey:@"completedDownloadsURLs"];
            
            NSArray *completedDownloadsStatusess = [[NSUserDefaults standardUserDefaults] objectForKey:@"completedDownloadsStatuses"];
            
            NSMutableArray *completedDownloadsNames = [[NSMutableArray alloc] initWithArray:completedDownloadsNamess];
            
            NSMutableArray *completedDownloadsURLs = [[NSMutableArray alloc] initWithArray:completedDownloadsURLss];
            
            NSMutableArray *completedDownloadsStatuses = [[NSMutableArray alloc] initWithArray:completedDownloadsStatusess];
            
            if (download.fileName != nil || ![download.fileName isEqualToString:@""]) {
                
                [completedDownloadsNames insertObject:download.fileName atIndex:0];
                
            } else {
                
                [completedDownloadsNames insertObject:[NSString stringWithFormat:@"No Name"] atIndex:0];
                
            }
            
            if (fileIdentifier != nil || ![fileIdentifier isEqualToString:@""]) {
                
                [completedDownloadsURLs insertObject:fileIdentifier atIndex:0];
                
            } else {
                
                [completedDownloadsURLs insertObject:[NSString stringWithFormat:@"No URL"] atIndex:0];
                
            }
            
            if (logMessage != nil || ![logMessage isEqualToString:@""]) {
                
                [completedDownloadsStatuses insertObject:logMessage atIndex:0];
                
            } else {
                
                [completedDownloadsStatuses insertObject:[NSString stringWithFormat:@"Unknown Status"] atIndex:0];
                
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:completedDownloadsNames forKey:@"completedDownloadsNames"];
            [[NSUserDefaults standardUserDefaults] setObject:completedDownloadsURLs forKey:@"completedDownloadsURLs"];
            [[NSUserDefaults standardUserDefaults] setObject:completedDownloadsStatuses forKey:@"completedDownloadsStatuses"];
            
            // remove object from the download
            [self.downloads removeObjectForKey:fileIdentifier];
        }
            
        }
        
}

- (CGFloat)remainingTimeForDownload:(TWRDownloadObject *)download
                   bytesTransferred:(int64_t)bytesTransferred
          totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:download.startDate];
    CGFloat speed = (CGFloat)bytesTransferred / (CGFloat)timeInterval;
    CGFloat remainingBytes = totalBytesExpectedToWrite - bytesTransferred;
    CGFloat remainingTime =  remainingBytes / speed;
    return remainingTime;
}

#pragma mark - File Management

- (BOOL)createDirectoryNamed:(NSString *)directory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    NSString *targetDirectory = [cachesDirectory stringByAppendingPathComponent:directory];

    NSError *error;
    return [[NSFileManager defaultManager] createDirectoryAtPath:targetDirectory
                                     withIntermediateDirectories:YES
                                                      attributes:nil
                                                           error:&error];
}

- (NSURL *)cachesDirectoryUrlPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    NSURL *cachesDirectoryUrl = [NSURL fileURLWithPath:cachesDirectory];
    return cachesDirectoryUrl;
}

- (BOOL)fileDownloadCompletedForUrl:(NSString *)fileIdentifier {
    BOOL retValue = YES;
    TWRDownloadObject *download = [self.downloads objectForKey:fileIdentifier];
    if (download) {
        // downloads are removed once they finish
        retValue = NO;
    }
    return retValue;
}

- (BOOL)isFileDownloadingForUrl:(NSString *)fileIdentifier {
    return [self isFileDownloadingForUrl:fileIdentifier
                       withProgressBlock:nil];
}

- (BOOL)isFileDownloadingForUrl:(NSString *)fileIdentifier
              withProgressBlock:(void(^)(CGFloat progress))block {
    return [self isFileDownloadingForUrl:fileIdentifier
                       withProgressBlock:block
                         completionBlock:nil];
}

- (BOOL)isFileDownloadingForUrl:(NSString *)fileIdentifier
              withProgressBlock:(void(^)(CGFloat progress))block
                completionBlock:(void(^)(BOOL completed))completionBlock {
    BOOL retValue = NO;
    TWRDownloadObject *download = [self.downloads objectForKey:fileIdentifier];
    if (download) {
        if (block) {
            download.progressBlock = block;
        }
        if (completionBlock) {
            download.completionBlock = completionBlock;
        }
        retValue = YES;
    }
    return retValue;
}

#pragma mark File existance

- (NSString *)localPathForFile:(NSString *)fileIdentifier {
    return [self localPathForFile:fileIdentifier inDirectory:nil];
}

- (NSString *)localPathForFile:(NSString *)fileIdentifier inDirectory:(NSString *)directoryName {
    NSString *fileName = [fileIdentifier lastPathComponent];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    return [[cachesDirectory stringByAppendingPathComponent:directoryName] stringByAppendingPathComponent:fileName];
}

- (BOOL)fileExistsForUrl:(NSString *)urlString {
    return [self fileExistsForUrl:urlString inDirectory:nil];
}

- (BOOL)fileExistsForUrl:(NSString *)urlString inDirectory:(NSString *)directoryName {
    return [self fileExistsWithName:[urlString lastPathComponent] inDirectory:directoryName];
}

- (BOOL)fileExistsWithName:(NSString *)fileName
               inDirectory:(NSString *)directoryName {
    BOOL exists = NO;

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];

    // if no directory was provided, we look by default in the base cached dir
    if ([[NSFileManager defaultManager] fileExistsAtPath:[[cachesDirectory stringByAppendingPathComponent:directoryName] stringByAppendingPathComponent:fileName]]) {
        exists = YES;
    }

    return exists;
}

- (BOOL)fileExistsWithName:(NSString *)fileName {
    return [self fileExistsWithName:fileName inDirectory:nil];
}

#pragma mark File deletion

- (BOOL)deleteFileForUrl:(NSString *)urlString {
    return [self deleteFileForUrl:urlString inDirectory:nil];
}

- (BOOL)deleteFileForUrl:(NSString *)urlString inDirectory:(NSString *)directoryName {
    return [self deleteFileWithName:[urlString lastPathComponent] inDirectory:directoryName];
}

- (BOOL)deleteFileWithName:(NSString *)fileName {
    return [self deleteFileWithName:fileName inDirectory:nil];
}

- (BOOL)deleteFileWithName:(NSString *)fileName
               inDirectory:(NSString *)directoryName {
    BOOL deleted = NO;

    NSError *error;
    NSURL *fileLocation;
    if (directoryName) {
        fileLocation = [[[self cachesDirectoryUrlPath] URLByAppendingPathComponent:directoryName] URLByAppendingPathComponent:fileName];
    } else {
        fileLocation = [[self cachesDirectoryUrlPath] URLByAppendingPathComponent:fileName];
    }


    // Move downloaded item from tmp directory to te caches directory
    // (not synced with user's iCloud documents)
    [[NSFileManager defaultManager] removeItemAtURL:fileLocation error:&error];

    if (error) {
        deleted = NO;
        NSLog(@"Error deleting file: %@", error);
    } else {
        deleted = YES;
    }
    return deleted;
}

#pragma mark - Clean directory

- (void)cleanDirectoryNamed:(NSString *)directory {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    for (NSString *file in [fm contentsOfDirectoryAtPath:directory error:&error]) {
        [fm removeItemAtPath:[directory stringByAppendingPathComponent:file] error:&error];
    }
}

- (void)cleanTmpDirectory {
    NSArray* tmpDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL];
    for (NSString *file in tmpDirectory) {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), file] error:NULL];
    }
}

#pragma mark - Background download

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    // Check if all download tasks have been finished.
    [session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if ([downloadTasks count] == 0) {
            if (self.backgroundTransferCompletionHandler != nil) {
                // Copy locally the completion handler.
                void(^completionHandler)() = self.backgroundTransferCompletionHandler;

                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    // Call the completion handler to tell the system that there are no other background transfers.
                    completionHandler();

                    // Show a local notification when all downloads are over.
                    // [todo]
                }];

                // Make nil the backgroundTransferCompletionHandler.
                self.backgroundTransferCompletionHandler = nil;
            }
        }
    }];
}

@end
