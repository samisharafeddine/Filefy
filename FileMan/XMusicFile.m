//
//  XMusicFile.m
//  FileMan
//
//  Created by Sami Sharaf on 2/17/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import "XMusicFile.h"

@implementation XMusicFile

-(instancetype)initWithPath:(NSURL *)path {
    self = [super init];
    
    self.path = path;
    
    return self;
    
}

- (void)fetchMetadata {
    
    self.songTitle = [self songTitleForFileAtPath:self.path];
    self.artistName = [self songArtistForFileAtPath:self.path];
    self.albumName = [self albumNameForFileAtPath:self.path];
    self.albumArtwork = [self albumArtworkForFileAtPath:self.path];
    
}

-(NSString *)songTitleForFileAtPath:(NSURL *)path {
    
    NSString *songTitle;
    
    BOOL found = NO;
    
    AVAsset *assest = [AVURLAsset URLAssetWithURL:path options:nil];
    
    for (NSString *format in [assest availableMetadataFormats]) {
        
        for (AVMetadataItem *item in [assest metadataForFormat:format]) {
            
            if ([[item commonKey] isEqualToString:@"title"]) {
                
                songTitle = (NSString *)[item value];
                found = YES;
                break;
                
            }
            
        }
        
    }
    
    if (!found) {
        
        NSString *pathString = [path path];
        NSString *fileName = pathString.lastPathComponent;
        
        songTitle = fileName.stringByDeletingPathExtension;
        
    }
    
    return songTitle;
    
}

-(NSString *)songArtistForFileAtPath:(NSURL *)path {
    
    NSString *songArtist;
    
    BOOL found = NO;
    
    AVAsset *assest = [AVURLAsset URLAssetWithURL:path options:nil];
    
    for (NSString *format in [assest availableMetadataFormats]) {
        
        for (AVMetadataItem *item in [assest metadataForFormat:format]) {
            
            if ([[item commonKey] isEqualToString:@"artist"]) {
                
                songArtist = (NSString *)[item value];
                found = YES;
                break;
                
            }
            
        }
        
    }
    
    if (!found) {
        
        songArtist = @"Unknown Artist";
        
    }
    
    return songArtist;
    
}

-(NSString *)albumNameForFileAtPath:(NSURL *)path {
    
    NSString *albumName;
    
    BOOL found = NO;
    
    AVAsset *assest = [AVURLAsset URLAssetWithURL:path options:nil];
    
    for (NSString *format in [assest availableMetadataFormats]) {
        
        for (AVMetadataItem *item in [assest metadataForFormat:format]) {
            
            if ([[item commonKey] isEqualToString:@"albumName"]) {
                
                albumName = (NSString *)[item value];
                found = YES;
                break;
                
            }
            
        }
        
    }
    
    if (!found) {
        
        albumName = @"Unknown Album";
        
    }
    
    return albumName;
    
}

-(UIImage *)albumArtworkForFileAtPath:(NSURL *)path {
    
    UIImage *albumArtwork;
    
    BOOL found = NO;
    
    AVAsset *asset = [AVAsset assetWithURL:path];
    
    for (AVMetadataItem *metadataItem in asset.commonMetadata) {
        
        if ([metadataItem.commonKey isEqualToString:@"artwork"]){
            
            albumArtwork = [UIImage imageWithData:(NSData *)metadataItem.value];
            found = YES;
            break;
            
        }
        
    }
    
    if (!found) {
        
        albumArtwork = [UIImage imageNamed:@"Album"];
        
    }
    
    return albumArtwork;
    
}

@end
