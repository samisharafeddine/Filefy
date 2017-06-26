//
//  MusicPlayerViewController.h
//  FileMan
//
//  Created by Sami Sharaf on 2/19/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MusicPlayerViewController : UIViewController <AVAudioPlayerDelegate, UIGestureRecognizerDelegate> {
    
    NSTimer *timer;
    BOOL repeatAllEnabled;
    BOOL repeatSongEnabled;
    BOOL shuffleEnabled;
    
}

@property NSUInteger *index;
@property NSMutableArray *musicFiles;
@property BOOL fromSelection;

+(instancetype)sharedInstance;
-(void)playOrPause;
-(void)back;
-(void)next:(BOOL)fromDelegate;

@end
