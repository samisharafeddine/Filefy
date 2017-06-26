/*
 *
 * Copyright (c) 2014-2017 Sami Sharaf. All rights reserved.
 * Created on 3/2/2017
 *
 * This XFileParser was made to ease in the development of file managers.
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

#import "XFileParser.h"
#import "XFile.h"

@implementation XFileParser

/*
 *
 * Method that scans Files in Directory for a given path.
 * Input is path as NSString.
 * Output is an Array of XFile Objects.
 *
 */

-(NSMutableArray *)filesInDirectory:(NSString *)path {
    
    /// Scan path and return an array of files within.
    NSArray *fileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    
    NSMutableArray *filePaths = [[NSMutableArray alloc] init]; /// Initialize mutable array of paths.
    NSMutableArray *XFiles = [[NSMutableArray alloc] init]; /// Initialize mutable array of XFile Objects.
    NSMutableArray *sortedXFiles = [[NSMutableArray alloc] init]; /// Initialize mutable array of sorted XFile Objects.
    
    /* File Parsing */
    
    for (int i = 0; i < fileNames.count; i++) {
        
        /// Get full path of a file from filenames array at index i.
        NSString *filePath = [self pathForFile:fileNames[i] andPath:path];
        
        [filePaths addObject:filePath]; /// Add full filepath to path array.
        
    }
    
    for (int i = 0; i < filePaths.count; i++) {
        
        /// Initialize a new XFile Object with file path from file paths array at index i, and initialize XFile with it.
        XFile *file = [[XFile alloc] initWithPath:filePaths[i]];
        
        [XFiles addObject:file]; /// Add XFile Object to XFiles array.
        
    }
    
    sortedXFiles = [NSMutableArray arrayWithArray:[self sortXFilesAlphabetically:XFiles]]; /// Sort XFiles array and return then in new array.
    
    return sortedXFiles; /// Return array of XFile Objects.
    
}

/*
 *
 * Method to build path for a given File at a given Directory.
 * Input is file as NSString, and path as NSString.
 * Output is an NSString of full filepath.
 *
 */

-(NSString *)pathForFile:(NSString *)file andPath:(NSString *)path {
    
    /// Return full path of file by combining path and filename as path components.
    return [path stringByAppendingPathComponent:file];
    
}

/*
 *
 * Method that sorts array of XFiles Alpabetically depending on display name value.
 * Input is array of XFile Objects.
 * Output is an Array of sorted XFile Objects.
 *
 */

-(NSArray *)sortXFilesAlphabetically:(NSMutableArray *)XFilesArray {
    
    NSArray *sortedXfiles; /// Initialize sorted XFile Objects array.
    
    /// Sort descriptor is Display name.
    NSArray *sortDesriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES selector:@selector(caseInsensitiveCompare:)]];
    sortedXfiles = [XFilesArray sortedArrayUsingDescriptors:sortDesriptors]; /// Sort array using sort descriptor.
    
    return sortedXfiles; /// Return array of sorted XFile Objects.
    
}

@end
