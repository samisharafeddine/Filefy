/*
 *
 * Copyright (c) 2014-2017 Sami Sharaf. All rights reserved.
 * Created on 3/2/2017
 *
 * This XFile Object was made to ease in the development of file managers.
 *
 * Originally part of FileMan project which can be found on the App Store.
 *
 */

/*
 *
 * Copyright (c) 2017 Sami Sharaf
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 */

#import "XFile.h"

@implementation XFile

@synthesize displayName; // File Display Name.
@synthesize isDirectory; // BOOL, Returns YES if Directory.
@synthesize fileExtension; // File Extenssion.
@synthesize filePath; // File Path as NSString.
@synthesize fileType; // File Type.
@synthesize fileAttributes; // File Attributes Dictionary.

/*
 *
 * Initialize XFile Object with its components.
 * Input is path as NSString.
 * Output is an XFile Object.
 *
 */

-(instancetype)initWithPath:(NSString *)path {
    self = [super init];
    
    self.displayName = path.lastPathComponent; /// Assigns Display Name.
    self.filePath = path; /// Assigns File Path according to the input path.
    self.isDirectory = [self checkIfDirectory:path]; /// Calls method to check if the path is a Directory, Returns BOOL.
    
    if (self.isDirectory) {
        
        /// If this is a Directory, there would be no File Extension and no File Attributes, assign Size, and assign File Type as "directory" for later use.
        
        self.fileExtension = nil;
        self.fileType = @"directory";
        self.fileAttributes = nil;
        self.fileSize = [self sizeForFolderAtPath:path];
        
    } else {
        
        /// If this is not a Directory, assign File Extension and File Attributes and File Size, and call method to determine what type of file is it.
        
        self.fileExtension = [path pathExtension];
        [self assignFileType:path];
        self.fileAttributes = [self attributesForFileAtPath:path];
        self.fileSize = [self sizeForFileAtPath:path];
        
    }
    
    /// init method returns XFile Object.
    
    return self;
    
}

/*
 *
 * Check if file at path is a Directory or not.
 * Takes value "path" as NSString input.
 * Returns BOOL.
 *
 */

-(BOOL)checkIfDirectory:(NSString *)path {
    
    BOOL isDir = NO;
    
    [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
    
    return isDir;
    
}

/*
 *
 * Checks the file extension of the file at path.
 * Supported Image formats: .gif, .jpg, .jpeg, .png, Returns File Type "image".
 * Supported Video formats: .mp4, .mov, .avi, .3gp, Returns File Type "video".
 * Supported Audio formats: .mp3, .m4a, .wav, Returns File Type "audio".
 * Archives (.zip), Documents (.pdf), Text (.txt), Json (.json), Returns "archive", "pdf", "txt", "json" respectively.
 * If File Extension is not recognized, Return "unknown".
 *
 */

-(void)assignFileType:(NSString *)path {
    
    if ([[path.lowercaseString pathExtension] isEqualToString:@"gif"] || [[path.lowercaseString pathExtension] isEqualToString:@"jpg"] || [[path.lowercaseString pathExtension] isEqualToString:@"jpeg"] || [[path.lowercaseString pathExtension] isEqualToString:@"png"]) {
        
        fileType = @"image";
        
    } else if ([[path.lowercaseString pathExtension] isEqualToString:@"mp4"] || [[path.lowercaseString pathExtension] isEqualToString:@"mov"] || [[path.lowercaseString pathExtension] isEqualToString:@"flv"] || [[path.lowercaseString pathExtension] isEqualToString:@"avi"] || [[path.lowercaseString pathExtension] isEqualToString:@"3gp"]) {
        
        fileType = @"video";
        
    } else if ([[path.lowercaseString pathExtension] isEqualToString:@"mp3"] || [[path.lowercaseString pathExtension] isEqualToString:@"m4a"] || [[path.lowercaseString pathExtension] isEqualToString:@"wav"]) {
        
        fileType = @"audio";
        
    } else if ([[path.lowercaseString pathExtension] isEqualToString:@"pdf"]) {
        
        fileType = @"pdf";
        
    } else if ([[path.lowercaseString pathExtension] isEqualToString:@"zip"]) {
        
        fileType = @"archive";
        
    } else if ([[path.lowercaseString pathExtension] isEqualToString:@"txt"]) {
        
        fileType = @"txt";
        
    } else if ([[path.lowercaseString pathExtension] isEqualToString:@"dmg"]) {
        
        fileType = @"disk image";
        
    } else if ([[path.lowercaseString pathExtension] isEqualToString:@"json"]) {
        
        fileType = @"json";
        
    } else {
        
        fileType = @"unknown";
        
    }
    
}

/*
 *
 * Gets file attributes if file is not a directory.
 * Input is path as NSString.
 * Output is an NSDictionary of attributes.
 *
 */

-(NSDictionary *)attributesForFileAtPath:(NSString *)path {
    
    NSDictionary *attributes;
    
    attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    
    return attributes;
    
}

/*
 *
 * Gets file size if file is a directory.
 * Input is path as NSString.
 * Output is an NSString of Size.
 *
 */

-(NSString *)sizeForFileAtPath:(NSString *)path {
    
    NSString *size = [NSByteCountFormatter stringFromByteCount:self.fileAttributes.fileSize countStyle:NSByteCountFormatterCountStyleFile];
    
    if ([size containsString:@"Zero"]) {
        
        size = @"Empty File";
        
    }
    
    return size;
    
}

/*
 *
 * Gets file size if file is not a directory.
 * Input is path as NSString.
 * Output is an NSString of Size.
 *
 */

-(NSString *)sizeForFolderAtPath:(NSString *)path {
    
    NSString *size = [NSByteCountFormatter stringFromByteCount:[self folderSize:path] countStyle:NSByteCountFormatterCountStyleFile];
    
    if ([size containsString:@"Zero"]) {
        
        size = @"Empty Folder";
        
    }
    
    return size;
    
}

/*
 *
 * Scans directory and gets the size of each item and subpath, adds all sizes, and gets the total size.
 * Input is path as NSString.
 * Output is an unsigned long long int of Bytes Count.
 *
 */

-(unsigned long long int)folderSize:(NSString *)folderPath {
    
    NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
    NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
    NSString *fileName;
    unsigned long long int fileSize = 0;
    
    while (fileName = [filesEnumerator nextObject]) {
        
        NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:fileName] error:nil];
        
        fileSize += [fileDictionary fileSize];
        
    }
    
    return fileSize;
    
}
  
@end
