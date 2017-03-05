//
//  PDFViewerViewController.h
//  FileMan
//
//  Created by Sami Sharaf on 2/8/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PDFViewerViewController : UIViewController

@property (strong, nonatomic) NSURL *pdfURL;
@property (strong, nonatomic) NSString *pdfTitle;

@end
