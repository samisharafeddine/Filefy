//
//  DownloadManager.m
//  FileMan
//
//  Created by Sami Sharaf on 3/1/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import "DownloadManager.h"
#import "DownloadItem.h"
#import "AppDelegate.h"

@implementation DownloadManager

+(instancetype)sharedManager {
    
    static id sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedManager = [[self alloc] init];
        
    });
    
    return sharedManager;
    
}

-(instancetype)init {
    self = [super init];
    
    if (self) {
        
        self.currentDownloads = [[NSMutableArray alloc] init];
        
        // Background session
        self.session = [self backgroundSession];
        
        NSArray *URLs = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
        self.documentsDir = [URLs objectAtIndex:0];
        
    }
    
    return self;
    
}

-(NSURLSession *)backgroundSession {
    
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.Sami-Sharaf.FileMan.session"];
        sessionConfiguration.HTTPMaximumConnectionsPerHost = [[NSUserDefaults standardUserDefaults] integerForKey:@"maxDownloads"];
        sessionConfiguration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        
        session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                     delegate:self
                                                delegateQueue:nil];
        
        NSLog(@"Session Initialized");
        
    });
    
    return session;
    
}

-(void)downloadFileAtURL:(NSURL *)url withName:(NSString *)name {
    
    DownloadItem *downloadItem = [[DownloadItem alloc] initWithFileTitle:name andDownloadSource:url];
    
    if (!downloadItem.isDownloading) {
        // This is the case where a download task should be started.
        
        // Create a new task, but check whether it should be created using a URL or resume data.
        if (downloadItem.taskIdentifier == -1) {
            // If the taskIdentifier property of the fdi object has value -1, then create a new task
            // providing the appropriate URL as the download source.
            downloadItem.downloadTask = [self.session downloadTaskWithURL:downloadItem.downloadSource];
            
            // Keep the new task identifier.
            downloadItem.taskIdentifier = downloadItem.downloadTask.taskIdentifier;
            
            // Start the task.
            [downloadItem.downloadTask resume];
            
        } else {
            // The resume of a download task will be done here.
            // Create a new download task, which will use the stored resume data.
            
            downloadItem.downloadTask = [self.session downloadTaskWithResumeData:downloadItem.taskResumeData];
            [downloadItem.downloadTask resume];
            
            // Keep the new download task identifier.
            downloadItem.taskIdentifier = downloadItem.downloadTask.taskIdentifier;
            
        }
        
    } else {
        
        [downloadItem.downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
            
            if (resumeData != nil) {
                downloadItem.taskResumeData = [[NSData alloc] initWithData:resumeData];
            }
            
        }];
        
    }
    
    downloadItem.isDownloading = !downloadItem.isDownloading;
    
    [self.currentDownloads insertObject:downloadItem atIndex:0];
    
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    if (totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown) {
        
        NSLog(@"Unknown transfer size");
        
    } else {
        
        // Locate the FileDownloadInfo object among all based on the taskIdentifier property of the task.
        int index = [self getFileDownloadInfoIndexWithTaskIdentifier:downloadTask.taskIdentifier];
        DownloadItem *downloadItem = [self.currentDownloads objectAtIndex:index];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            // Calculate the progress.
            downloadItem.downloadProgress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
            
            NSLog(@"Download Progress: %.2f, For Task: %lu", downloadItem.downloadProgress, downloadItem.taskIdentifier);
            
        }];
        
    }
    
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    // Change the flag values of the respective FileDownloadInfo object.
    int index = [self getFileDownloadInfoIndexWithTaskIdentifier:downloadTask.taskIdentifier];
    DownloadItem *downloadItem = [self.currentDownloads objectAtIndex:index];
    
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *destinationFilename = downloadItem.fileTitle;
    NSURL *destinationURL = [self.documentsDir URLByAppendingPathComponent:destinationFilename];
    NSURL *url;
    
    if ([fileManager fileExistsAtPath:[destinationURL path]]) {
        
        NSString *fileName = destinationFilename.stringByDeletingPathExtension;
        NSString *extension = destinationFilename.pathExtension;
        
        int i = 1;
        
        while (i != 0) {
            
            NSString *newFileName = [NSString stringWithFormat:@"%@-%d", fileName, i];
            NSString *fullName = [NSString stringWithFormat:@"%@.%@", newFileName, extension];
            
            url = [self.documentsDir URLByAppendingPathComponent:fullName];
            
            if ([fileManager fileExistsAtPath:[url path]]) {
                
                i++;
                
            } else {
                
                i = 0;
                
            }
            
        }
        
    } else {
        
        url = destinationURL;
        
    }
    
    BOOL success = [fileManager moveItemAtURL:location
                                        toURL:url
                                        error:&error];
    
    if (success) {
        
        downloadItem.isDownloading = NO;
        downloadItem.downloadComplete = YES;
        
        // Set the initial value to the taskIdentifier property of the fdi object,
        // so when the start button gets tapped again to start over the file download.
        downloadItem.taskIdentifier = -1;
        
        // In case there is any resume data stored in the fdi object, just make it nil.
        downloadItem.taskResumeData = nil;
        
        downloadItem.downloadComplete = YES;
        
    } else {
        
        NSLog(@"Unable to copy temp file. Error: %@", [error localizedDescription]);
        
    }
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    if (self.currentDownloads == nil) {
        
        NSLog(@"Failed Download");
        
    } else {
        
        int index = [self getFileDownloadInfoIndexWithTaskIdentifier:task.taskIdentifier];
        DownloadItem *item = [self.currentDownloads objectAtIndex:index];
        
        item.isDownloading = NO;
        item.taskIdentifier = -1;
        item.taskResumeData = nil;
        
        item.didFail = YES;
        
    }
    
}

-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    // Check if all download tasks have been finished.
    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if ([downloadTasks count] == 0) {
            if (appDelegate.backgroundTransferCompletionHandler != nil) {
                // Copy locally the completion handler.
                void(^completionHandler)() = appDelegate.backgroundTransferCompletionHandler;
                
                // Make nil the backgroundTransferCompletionHandler.
                appDelegate.backgroundTransferCompletionHandler = nil;
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    // Call the completion handler to tell the system that there are no other background transfers.
                    completionHandler();
                    
                    NSLog(@"Downloads Completed");
                    
                    // Show a local notification when all downloads are over.
                    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                    localNotification.alertBody = @"All files have been downloaded!";
                    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
                }];
            }
        }
    }];
}

-(int)getFileDownloadInfoIndexWithTaskIdentifier:(unsigned long)taskIdentifier {
    
    int index = 0;
    
    for (int i = 0; i < self.currentDownloads.count; i++) {
        
        DownloadItem *downloadItem = [self.currentDownloads objectAtIndex:i];
        
        if (downloadItem.taskIdentifier == taskIdentifier) {
            
            index = i;
            break;
            
        }
        
    }
    
    return index;
    
}

@end
