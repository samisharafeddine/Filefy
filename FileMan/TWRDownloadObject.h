//
//  TWRDownloadObject.h
//  DownloadManager
//
//  Created by Michelangelo Chasseur on 26/07/14.
//  Copyright (c) 2014 Touchware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGBase.h>

typedef void(^TWRDownloadRemainingTimeBlock)(NSUInteger seconds);
typedef void(^TWRDownloadProgressBlock)(CGFloat progress);
typedef void(^TWRDownloadCompletionBlock)(BOOL completed);
typedef void(^TWRDownloadInfoBlock)(NSString *info);

@interface TWRDownloadObject : NSObject

@property (copy, nonatomic) TWRDownloadProgressBlock progressBlock;
@property (copy, nonatomic) TWRDownloadCompletionBlock completionBlock;
@property (copy, nonatomic) TWRDownloadRemainingTimeBlock remainingTimeBlock;
@property (copy, nonatomic) TWRDownloadInfoBlock infoBlock;

@property (strong, nonatomic) NSURLSessionDownloadTask *downloadTask;
@property (copy, nonatomic) NSString *fileName;
@property (copy, nonatomic) NSDate *startDate;

- (instancetype)initWithDownloadTask:(NSURLSessionDownloadTask *)downloadTask
                       progressBlock:(TWRDownloadProgressBlock)progressBlock
                       remainingTime:(TWRDownloadRemainingTimeBlock)remainingTimeBlock
                     completionBlock:(TWRDownloadCompletionBlock)completionBlock
                           infoBlock:(TWRDownloadInfoBlock)infoBlock;

@end
