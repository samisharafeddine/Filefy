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

#import <Foundation/Foundation.h>

@interface XFile : NSObject

@property NSString *displayName; /// Display name property.
@property BOOL isDirectory; /// If its a directory.
@property NSString *fileExtension; /// File extension property.
@property NSString *filePath; /// File path property.
@property NSString *fileType; /// File type property.
@property NSDictionary *fileAttributes; /// File attributes property.
@property NSString *fileSize; /// File size property.

-(instancetype)initWithPath:(NSString *)url; /// Custom initializer.

@end
