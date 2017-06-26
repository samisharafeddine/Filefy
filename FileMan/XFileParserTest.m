/*
 *
 * Copyright (c) 2014-2017 Sami Sharaf. All rights reserved.
 * Created on 3/2/2017
 *
 * This XFileParserTest was made to ease in the development of file managers.
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

#import "XFileParserTest.h"
#import "XFile.h"

@implementation XFileParserTest

/// Method that logs XFile Objects in XFile Object array.

-(void)logXFileObjectsInArray:(NSArray *)XFilesArray {
    
    NSLog(@"XFile Objects Array: %@", XFilesArray);
    
}

/// Method that logs every XFile Object details from XFile Object array.

-(void)logXFileObjectsDetailsFromArray:(NSArray *)XFilesArray {
    
    /* Detail logging */
    
    /// Scans XFile Object array and logs details of each XFile Object.
    for (int i = 0; i < XFilesArray.count; i++) {
        
        NSLog(@"XFile Object [%i]:", (i+1)); /// Log XFile Object number in array (NOT ITS ARRAY INDEX).
        
        XFile *XFileObject = XFilesArray[i]; /// Tell computer that objects in this array are XFile Objects.
        
        NSLog(@"File Display Name: %@", XFileObject.displayName); /// Log Display name of XFile Object.
        
        NSString *isDir; /// We need that to return a readable message of a BOOL value.
        
        /// BOOL value translation.
        if (XFileObject.isDirectory == YES) {
            
            isDir = @"YES"; /// BOOL is YES, XFile Object IS a directory.
            
        } else {
            
            isDir = @"NO"; /// BOOL is NO, XFile Object IS NOT a directory.
            
        }
        
        NSLog(@"Is Directory: %@", isDir); /// Log if XFile Object is a directory (YES or NO).
        NSLog(@"File Extension: %@", XFileObject.fileExtension); /// Logs the file extension.
        NSLog(@"File Type: %@", XFileObject.fileType); /// Logs file type.
        NSLog(@"File Path: %@", XFileObject.filePath); /// Logs the full file path in the system.
        NSLog(@"File Attributes: %@", XFileObject.fileAttributes); /// Logs file attributes.
        NSLog(@"File Size: %@", XFileObject.fileSize); /// Logs file size.
        NSLog(@"\n"); /// New line in order not to get blinded by the logged messages :]
        
    }
    
}

@end
