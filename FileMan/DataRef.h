//
//  DataRef.h
//  FileMan
//
//  Created by Sami Sharaf on 1/18/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataRef : NSObject {
    
    BOOL didPassBookmarkURL;
    BOOL isMovingItems;
    BOOL isCopyingItems;
    BOOL hasPlayedOnce;
    BOOL isPlaying;
    BOOL lock;
    
}

@property NSURL *passedBookmarkURL;
@property BOOL didPassBookmarkURL;
@property BOOL isMovingItems;
@property NSMutableArray *filesToBeMoved;
@property NSMutableArray *filesToBeCopied;
@property BOOL isCopyingItems;
@property BOOL hasPlayedOnce;
@property BOOL isPlaying;
@property BOOL lock;

@end
