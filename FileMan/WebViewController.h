//
//  WebViewController.h
//  FileMan
//
//  Created by Sami Sharaf on 12/28/16.
//  Copyright © 2016 Sami Sharaf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface WebViewController : UIViewController <UITextFieldDelegate, UIWebViewDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, NSURLConnectionDelegate> {
    
    BOOL loadCompleted;
    NSTimer *loadTimer;
    BOOL toolbarHidden;
    CGFloat lastContentOffsetY;
    UIButton *refresh;
    
}

@end
