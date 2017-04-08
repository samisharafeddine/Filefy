//
//  WebViewController.h
//  FileMan
//
//  Created by Sami Sharaf on 12/28/16.
//  Copyright © 2016 Sami Sharaf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "LTHPasscodeViewController.h"

@interface WebViewController : UIViewController <UITextFieldDelegate, UIWebViewDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, NSURLConnectionDelegate, LTHPasscodeViewControllerDelegate> {
    
    BOOL loadCompleted;
    NSTimer *loadTimer;
    BOOL toolbarHidden;
    CGFloat lastContentOffsetY;
    UIButton *refresh;
    BOOL didEnterPasscode;
    
}

@end
