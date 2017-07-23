//
//  MusicPlayerViewController.m
//  FileMan
//
//  Created by Sami Sharaf on 2/19/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import "MusicPlayerViewController.h"
#import "XMusicFile.h"
#import "AppDelegate.h"

#include <stdlib.h>
#include <Crashlytics/Crashlytics.h>

@import Firebase;

@interface MusicPlayerViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *albumArtwork;
@property (weak, nonatomic) IBOutlet UIImageView *blurredAlbumArtwork;
@property (weak, nonatomic) IBOutlet UILabel *songName;
@property (weak, nonatomic) IBOutlet UILabel *artistName;
@property (weak, nonatomic) IBOutlet UILabel *timeElapsed;
@property (weak, nonatomic) IBOutlet UILabel *timeRemaining;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet UIButton *repeatButton;
@property (weak, nonatomic) IBOutlet UIButton *shuffleButton;
@property (weak, nonatomic) IBOutlet UISlider *songSlider;
@property (weak, nonatomic) IBOutlet UIView *volumeSliderView;
@property (weak, nonatomic) IBOutlet UIView *airPlayView;

@property (strong, nonatomic) AVAudioPlayer *player;

@end

@implementation MusicPlayerViewController {
    
    AppDelegate *appDelegate;
    
}

@synthesize fromSelection;

+(instancetype)sharedInstance {
    
    static MusicPlayerViewController *sharedInstanceVC = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,^{
        
        sharedInstanceVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"musicPlayerViewController"];
        
    });
    
    return sharedInstanceVC;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //assert(NO);
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.songName.layer.shadowOpacity = 0.8;
    self.songName.layer.shadowRadius = 5.0;
    self.songName.layer.shadowColor = [UIColor blackColor].CGColor;
    self.songName.layer.shadowOffset = CGSizeMake(0, 0);
    
    self.artistName.layer.shadowOpacity = 0.8;
    self.artistName.layer.shadowRadius = 5.0;
    self.artistName.layer.shadowColor = [UIColor blackColor].CGColor;
    self.artistName.layer.shadowOffset = CGSizeMake(0, 0);
    
    self.timeElapsed.layer.shadowOpacity = 0.8;
    self.timeElapsed.layer.shadowRadius = 5.0;
    self.timeElapsed.layer.shadowColor = [UIColor blackColor].CGColor;
    self.timeElapsed.layer.shadowOffset = CGSizeMake(0, 0);
    
    self.timeRemaining.layer.shadowOpacity = 0.8;
    self.timeRemaining.layer.shadowRadius = 5.0;
    self.timeRemaining.layer.shadowColor = [UIColor blackColor].CGColor;
    self.timeRemaining.layer.shadowOffset = CGSizeMake(0, 0);
    
    self.playButton.layer.shadowOpacity = 0.8;
    self.playButton.layer.shadowRadius = 5.0;
    self.playButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.playButton.layer.shadowOffset = CGSizeMake(0, 0);
    
    self.backButton.layer.shadowOpacity = 0.8;
    self.backButton.layer.shadowRadius = 5.0;
    self.backButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.backButton.layer.shadowOffset = CGSizeMake(0, 0);
    
    self.forwardButton.layer.shadowOpacity = 0.8;
    self.forwardButton.layer.shadowRadius = 5.0;
    self.forwardButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.forwardButton.layer.shadowOffset = CGSizeMake(0, 0);
    
    self.repeatButton.layer.shadowOpacity = 0.8;
    self.repeatButton.layer.shadowRadius = 5.0;
    self.repeatButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.repeatButton.layer.shadowOffset = CGSizeMake(0, 0);
    
    self.shuffleButton.layer.shadowOpacity = 0.8;
    self.shuffleButton.layer.shadowRadius = 5.0;
    self.shuffleButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.shuffleButton.layer.shadowOffset = CGSizeMake(0, 0);
    
    self.albumArtwork.layer.cornerRadius = 5;
    
    // TODO - Bugfix: - MPVolumeView UISlider and/or AirPlay Button Never shows, probably an iOS 11 Beta Bug.
    
    MPVolumeView *mpVolumeView = [[MPVolumeView alloc] initWithFrame:self.volumeSliderView.bounds];
    NSArray *tempArray = mpVolumeView.subviews;
    
    for (id current in tempArray){
        if ([current isKindOfClass:[UISlider class]]){
            
            UISlider *tempSlider = (UISlider *) current;
            tempSlider.minimumTrackTintColor = [UIColor whiteColor];
            tempSlider.maximumTrackTintColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.2];
            
        }
    }
    mpVolumeView.showsRouteButton = NO;
    [self.volumeSliderView addSubview:mpVolumeView];
    [mpVolumeView sizeToFit];
    
    MPVolumeView *mpAirplayView = [[MPVolumeView alloc] initWithFrame:self.airPlayView.bounds];
    mpAirplayView.showsVolumeSlider = NO;
    [self.airPlayView addSubview:mpAirplayView];
    [mpAirplayView sizeToFit];
    
    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissVc)];
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipeRecognizer];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [FIRAnalytics logEventWithName:@"Using_Music_Player" parameters:nil];
    [Answers logCustomEventWithName:@"Using_Music_Player" customAttributes:nil];
    
    if (self.fromSelection) {
        
        self.fromSelection = NO;
        [self playMusicFileAtIndex:self.index play:YES];
        
    }
    
    AppDelegate *shared = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    shared.blockRotation = YES;
    
    [self.navigationController setToolbarHidden:YES];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault]; // UIImageNamed:@"transparent.png"
    self.navigationController.navigationBar.shadowImage = [UIImage new]; // UIImageNamed:@"transparent.png"
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    AppDelegate *shared = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    shared.blockRotation = NO;
    
}

-(void)dismissVc {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/// Playing music files

-(void)playMusicFileAtIndex:(NSUInteger *)index play:(BOOL)play {
    
    [self stop];
    
    XMusicFile *musicFile = [self.musicFiles objectAtIndex:(NSUInteger)index];
    
    NSError *error;
    self.player = nil;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:musicFile.path error:&error];
    self.player.delegate = self;
    [musicFile fetchMetadata];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    if (musicFile.albumArtwork == nil) {
        
        musicFile.albumArtwork = [UIImage imageNamed:@"Album"];
        
    }
    
    MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:musicFile.albumArtwork];
    
    MPNowPlayingInfoCenter *playingInfo = [MPNowPlayingInfoCenter defaultCenter];
    [playingInfo setNowPlayingInfo:@{
                                     MPMediaItemPropertyTitle : musicFile.songTitle,
                                     MPMediaItemPropertyArtist : musicFile.artistName,
                                     MPMediaItemPropertyArtwork : artwork,
                                     MPNowPlayingInfoPropertyPlaybackRate : @1.0f,
                                     MPMediaItemPropertyPlaybackDuration : [NSString stringWithFormat:@"%f", self.player.duration],
                                     }];
    
    if (error) {
        
        [self errorMessage:error.localizedDescription];
        
    } else {
        
        [self updateAlbumImage:musicFile];
        [self updateSongLabels:musicFile];
        [self updateSliderControls];
        [self updateSliderValues];
        [self updateButtons];
        
        if (play == YES) {
            
            [self playOrPause];
            
        }
        
    }
    
}

-(void)playOrPause {
    
    if (self.player.playing) {
        
        [self stopTimer];
        [self.player pause];
        appDelegate.dataRef.isPlaying = NO;
        [self updateButtons];
        
    } else {
        
        [self.player play];
        [self startTimer];
        appDelegate.dataRef.isPlaying = YES;
        [self updateButtons];
        
    }
    
}

-(void)back {
    
    if (self.player.currentTime >= 4 || self.index == 0) {
        
        if (self.player.playing) {
            
            [self playMusicFileAtIndex:self.index play:YES];
            
        } else {
            
            [self playMusicFileAtIndex:self.index play:NO];
            
        }
        
    } else {
        
        NSInteger *indexInt = (NSInteger *)self.index;
        long newIndex = (long)indexInt - 1;
        self.index = (NSUInteger *)newIndex;
        
        if (self.player.playing) {
            
            [self playMusicFileAtIndex:self.index play:YES];
            
        } else {
            
            [self playMusicFileAtIndex:self.index play:NO];
            
        }
        
    }
    
}

-(void)next:(BOOL)fromDelegate {
    
    long count = self.musicFiles.count - 1;
    
    if (repeatAllEnabled) {
        
        if ((long)self.index == count) {
            
            self.index = 0;
            
            [self playMusicFileAtIndex:self.index play:YES];
            
        } else {
            
            if (shuffleEnabled) {
                
                long newIndex = (long)arc4random_uniform((int)self.musicFiles.count);
                self.index = (NSUInteger *)newIndex;
                
            } else {
                
                NSInteger *indexInt = (NSInteger *)self.index;
                long newIndex = (long)indexInt + 1;
                self.index = (NSUInteger *)newIndex;
                
            }
            
            if (fromDelegate) {
                
                [self playMusicFileAtIndex:self.index play:YES];
                
            } else {
                
                if (self.player.playing) {
                    
                    [self playMusicFileAtIndex:self.index play:YES];
                    
                } else {
                    
                    [self playMusicFileAtIndex:self.index play:NO];
                    
                }
                
            }
            
        }
        
    } else if (repeatSongEnabled) {
        
        if ((long)self.index == count) {
            
            if (fromDelegate) {
                
                [self playMusicFileAtIndex:self.index play:YES];
                
            } else {
                
                self.index = 0;
                
                [self playMusicFileAtIndex:self.index play:NO];
                
            }
            
        } else {
            
            if (fromDelegate) {
                
                [self playMusicFileAtIndex:self.index play:YES];
                
            } else {
                
                if (shuffleEnabled) {
                    
                    long newIndex = (long)arc4random_uniform((int)self.musicFiles.count);
                    self.index = (NSUInteger *)newIndex;
                    
                } else {
                    
                    NSInteger *indexInt = (NSInteger *)self.index;
                    long newIndex = (long)indexInt + 1;
                    self.index = (NSUInteger *)newIndex;
                    
                }
                
                [self playMusicFileAtIndex:self.index play:YES];
                
            }
            
        }
        
    } else {
        
        if ((long)self.index == count) {
            
            self.index = 0;
            
            if (shuffleEnabled) {
                
                [self playMusicFileAtIndex:self.index play:YES];
                
            } else {
                
                [self playMusicFileAtIndex:self.index play:NO];
                
            }
            
        } else {
            
            if (shuffleEnabled) {
                
                long newIndex = (long)arc4random_uniform((int)self.musicFiles.count);
                self.index = (NSUInteger *)newIndex;
                
            } else {
                
                NSInteger *indexInt = (NSInteger *)self.index;
                long newIndex = (long)indexInt + 1;
                self.index = (NSUInteger *)newIndex;
                
            }
            
            if (fromDelegate) {
                
                [self playMusicFileAtIndex:self.index play:YES];
                
            } else {
                
                if (self.player.playing) {
                    
                    [self playMusicFileAtIndex:self.index play:YES];
                    
                } else {
                    
                    [self playMusicFileAtIndex:self.index play:NO];
                    
                }
                
            }
            
        }
        
    }
    
}

-(void)stop {
    
    [self.player stop];
    [self stopTimer];
    [self updateButtons];
    [self updateSliderValues];
    
}

-(void)stopTimer {
    
    if (timer) {
        
        [timer invalidate];
        timer = nil;
        
    }
    
}

-(void)startTimer {
    
    if (!timer) {
        
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateSliderValues) userInfo:nil repeats:YES];
        
    }
    
}

/// Interface methods

-(void)updateAlbumImage:(XMusicFile *)musicFile {
    
    self.albumArtwork.image = musicFile.albumArtwork;
    self.blurredAlbumArtwork.image = [self blurredImageWithImage:musicFile.albumArtwork];
    
}

-(void)updateSongLabels:(XMusicFile *)musicFile {
    
    self.songName.text = musicFile.songTitle;
    self.artistName.text = [NSString stringWithFormat:@"%@ - %@", musicFile.artistName, musicFile.albumName];
    
}

-(void)updateSliderValues {
    
    self.songSlider.value = self.player.currentTime;
    self.timeElapsed.text = [self stringFromTimeInterval:self.player.currentTime];
    self.timeRemaining.text = [NSString stringWithFormat:@"-%@", [self stringFromTimeInterval:(self.player.duration - self.player.currentTime)]];
    
}

-(void)updateTimeLabels {
    
    self.timeElapsed.text = [self stringFromTimeInterval:self.songSlider.value];
    self.timeRemaining.text = [NSString stringWithFormat:@"-%@", [self stringFromTimeInterval:(self.player.duration - self.songSlider.value)]];
    
}

-(void)updateSliderControls {
    
    self.songSlider.minimumValue = 0;
    self.songSlider.maximumValue = self.player.duration;
    
}

-(void)updateButtons {
    
    if (self.player.playing) {
        
        [self.playButton setImage:[UIImage imageNamed:@"PauseButton"] forState:UIControlStateNormal];
        
    } else {
        
        [self.playButton setImage:[UIImage imageNamed:@"PlayButton"] forState:UIControlStateNormal];
        
    }
    
}

/// Actions

-(IBAction)playButtonPressed:(id)sender {
    
    FIRCrashLog(@"Play song");
    CLS_LOG(@"Play song");
    
    [self playOrPause];
    
}

-(IBAction)goBackPressed:(id)sender {
    
    FIRCrashLog(@"GoBack song");
    CLS_LOG(@"GoBack song");
    
    [self back];
    
}

-(IBAction)goForwardPressed:(id)sender {
    
    FIRCrashLog(@"GoForward Song");
    CLS_LOG(@"GoForward Song");
    
    [self next:NO];
    
}

-(IBAction)repeatPressed:(id)sender {
    
    FIRCrashLog(@"Repeat pressed");
    CLS_LOG(@"Repeat pressed");
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *repeatAll = [UIAlertAction actionWithTitle:@"Repeat All" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        repeatSongEnabled = NO;
        repeatAllEnabled = YES;
        self.repeatButton.selected = YES;
        
    }];
    
    UIAlertAction *repeatSong = [UIAlertAction actionWithTitle:@"Repeat Song" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        repeatSongEnabled = YES;
        repeatAllEnabled = NO;
        self.repeatButton.selected = YES;
        
    }];
    
    UIAlertAction *repeatOff = [UIAlertAction actionWithTitle:@"Repeat Off" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        repeatAllEnabled = NO;
        repeatSongEnabled = NO;
        self.repeatButton.selected = NO;
        
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        // Cancels Action Sheet.
        
    }];
    
    actionSheet.view.tintColor = [UIColor blackColor];
    
    [actionSheet addAction:repeatOff];
    [actionSheet addAction:repeatSong];
    [actionSheet addAction:repeatAll];
    [actionSheet addAction:cancelAction];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
    
}

-(IBAction)shuffleButtonSelected:(id)sender {
    
    FIRCrashLog(@"Shufffle selected");
    CLS_LOG(@"Shufffle selected");
    
    if (!shuffleEnabled) {
        
        shuffleEnabled = YES;
        self.shuffleButton.selected = YES;
        
    } else {
        
        shuffleEnabled = NO;
        self.shuffleButton.selected = NO;
        
    }
    
}

-(IBAction)timeSliderValueChanged:(id)sender {
    
    FIRCrashLog(@"Time Slider Value changed");
    CLS_LOG(@"Time Slider Value changed");
    
    if (timer) {
        
        [self stopTimer];
        
    }
    
    [self updateTimeLabels];
    
}

-(IBAction)timeSliderFinishedChanging:(id)sender {
    
    FIRCrashLog(@"Time slider value finished changing");
    CLS_LOG(@"Time slider value finished changing");
    
    if (self.player.playing) {
        
        [self.player stop];
        self.player.currentTime = self.songSlider.value;
        [self.player prepareToPlay];
        [self startTimer];
        [self.player play];
        
    } else {
        
        [self.player stop];
        self.player.currentTime = self.songSlider.value;
        [self.player prepareToPlay];
        
    }
    
}

-(IBAction)hideMusicVC:(id)sender {
    
    FIRCrashLog(@"Hiding MusicVC");
    CLS_LOG(@"Hiding MusicVC");
    
    [self dismissVc];
    
}

/// Music player delegate

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    [self next:YES];
    
}

-(void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
    
    if (self.player.isPlaying) {
        
        [self playOrPause];
        
    }
    
}

-(void)audioPlayerEndInterruption:(AVAudioPlayer *)player {
    
    if (!self.player.isPlaying) {
        
        [self playOrPause];
        
    }
    
}

- (UIImage *)blurredImageWithImage:(UIImage *)sourceImage{
    
    //  Create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:sourceImage.CGImage];
    
    //  Setting up Gaussian Blur
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:15.0f] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    /*  CIGaussianBlur has a tendency to shrink the image a little, this ensures it matches
     *  up exactly to the bounds of our original image */
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    UIImage *retVal = [UIImage imageWithCGImage:cgImage];
    
    return retVal;
    
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    
    if (hours == 0) {
        
        return [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
        
    } else {
        
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
        
    }
    
}

-(void)errorMessage:(NSString *)error {
    
    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Error" message:error preferredStyle:UIAlertControllerStyleAlert];
    
    [self presentViewController:errorAlert animated:YES completion:^{
        
        [self performSelector:@selector(dismissError:) withObject:errorAlert afterDelay:2];
        
    }];
    
}

-(void)dismissError:(UIAlertController *)alert {
    
    [alert dismissViewControllerAnimated:YES completion:nil];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
