//
//  XMusicFile.h
//  FileMan
//
//  Created by Sami Sharaf on 2/17/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface XMusicFile : NSObject

@property NSURL *path;
@property NSString *songTitle;
@property NSString *artistName;
@property NSString *albumName;
@property UIImage *albumArtwork;

-(instancetype)initWithPath:(NSURL *)path;

@end
