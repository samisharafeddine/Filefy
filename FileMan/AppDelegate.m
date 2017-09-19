//
//  AppDelegate.m
//  FileMan
//
//  Created by Sami Sharaf on 12/28/16.
//  Copyright © 2016 Sami Sharaf. All rights reserved.
//

#import "AppDelegate.h"
#import "MusicPlayerViewController.h"
#import "TWRDownloadManager.h"
#import "LTHPasscodeViewController.h"
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@import Firebase;
@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self checkFirstTimeInstallation];
    [self setupAnalytics];
    [self setupDropbox];
    [self checkForUpdate];
    [self setupAppData];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    
    [self showPasscode];
    
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [self showPasscode];
    
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    
    if (self.blockRotation) {
        
        return UIInterfaceOrientationMaskPortrait;
        
    }
    
    return UIInterfaceOrientationMaskAll;
    
}

-(void)remoteControlReceivedWithEvent:(UIEvent *)event {
    
    if (event.type == UIEventTypeRemoteControl) {
        
        if (event.subtype == UIEventSubtypeRemoteControlPlay) {
            
            [[MusicPlayerViewController sharedInstance] playOrPause];
            
        } else if (event.subtype == UIEventSubtypeRemoteControlPause) {
            
            [[MusicPlayerViewController sharedInstance] playOrPause];
            
        } else if (event.subtype == UIEventSubtypeRemoteControlNextTrack) {
            
            [[MusicPlayerViewController sharedInstance] next:NO];
            
        } else if (event.subtype == UIEventSubtypeRemoteControlPreviousTrack) {
            
            [[MusicPlayerViewController sharedInstance] back];
            
        }
        
    }
    
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    [FIRAnalytics logEventWithName:@"Used_File_Importing" parameters:@{@"File_Type": [url pathExtension]}];
    [Answers logCustomEventWithName:@"Used_File_Importing" customAttributes:@{@"File_Type": [url pathExtension]}];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"openFile" object:url];
    
    return YES;
    
}

-(void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler {
    
    [TWRDownloadManager sharedManager].backgroundTransferCompletionHandler = completionHandler;
    
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    DBOAuthResult *authResult = [DBClientsManager handleRedirectURL:url];
    if (authResult != nil) {
        if ([authResult isSuccess]) {
            NSLog(@"Success! User is logged into Dropbox.");
        } else if ([authResult isCancel]) {
            NSLog(@"Authorization flow was manually canceled by user!");
        } else if ([authResult isError]) {
            NSLog(@"Error: %@", authResult);
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dropboxStatusChanged" object:nil];
        
    }
    return NO;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    DBOAuthResult *authResult = [DBClientsManager handleRedirectURL:url];
    if (authResult != nil) {
        if ([authResult isSuccess]) {
            NSLog(@"Success! User is logged into Dropbox.");
        } else if ([authResult isCancel]) {
            NSLog(@"Authorization flow was manually canceled by user!");
        } else if ([authResult isError]) {
            NSLog(@"Error: %@", authResult);
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dropboxStatusChanged" object:nil];
        
    }
    return NO;
    
}

- (void)setupNewInstallation {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"WelcomeController"];
    self.window.rootViewController = viewController;
    
    NSArray *defaultMIMEs = @[@"image/*",
                              @"audio/*",
                              @"video/*",
                              @"*/pdf",
                              @"*/rtf",
                              @"text/richtext",
                              @"application/msword",
                              @"application/vnd.ms-word*",
                              @"application/vnd.ms-excel*",
                              @"application/vnd.ms-powerpoint*",
                              @"application/vnd.iwork.*",
                              @"application/zip"];
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"titleHistory"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"urlHistory"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"hasURL"];
    [[NSUserDefaults standardUserDefaults] setObject:@"Google" forKey:@"SearchEngine"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"Homepage"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"bookmarkTitles"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"bookmarkURLs"];
    [[NSUserDefaults standardUserDefaults] setObject:defaultMIMEs forKey:@"defaultMIMETypes"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"downloads"];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"defaultTab"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"completedDownloadsNames"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"completedDownloadsURLs"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"completedDownloadsStatuses"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"TouchID"];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"timesLaunched"];
    [LTHPasscodeViewController deletePasscode];
    [[LTHPasscodeViewController sharedUser] setAllowUnlockWithTouchID:NO];
    [DBClientsManager unlinkAndResetClients];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)checkForUpdate {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *currentAppVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *previousVersion = [defaults objectForKey:@"appVersion"];
    if (!previousVersion) {
        // first launch, save current version
        
        [defaults setObject:currentAppVersion forKey:@"appVersion"];
        [defaults synchronize];
        
    } else {
        // Update detected
        
        [defaults setObject:currentAppVersion forKey:@"appVersion"];
        [defaults synchronize];
    }
    
}

- (void)setupAnalytics {
    [Fabric with:@[[Answers class], [Crashlytics class]]];
    [FIRApp configure];
}

- (void)setupDropbox {
    [DBClientsManager setupWithAppKey:@"6c12323v2c6pvn7"];
    
    if ([[DBClientsManager authorizedClient] isAuthorized]) {
        
        NSLog(@"DropBox Authorized");
        
    } else {
        
        NSLog(@"DropBox Not Authorized");
        
    }
}

- (void)checkFirstTimeInstallation {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"hasCompletedTutorial"]) {
        
        // Normal view
        
    } else {
        
        [self setupNewInstallation];
        
    }
}

- (void)setupAppData {
    self.dataRef = [[DataRef alloc] init];
    self.XFileParser = [[XFileParser alloc] init];
    
    NSInteger timesOpened = [[NSUserDefaults standardUserDefaults] integerForKey:@"timesLaunched"];
    
    if (timesOpened <= 2) {
        timesOpened++;
        [[NSUserDefaults standardUserDefaults] setInteger:timesOpened forKey:@"timesLaunched"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    self.dataRef.hasPlayedOnce = NO;
}

- (void)showPasscode {
    if ([LTHPasscodeViewController doesPasscodeExist]) {
        if ([LTHPasscodeViewController didPasscodeTimerEnd])
            [[LTHPasscodeViewController sharedUser] showLockScreenWithAnimation:YES
                                                                     withLogout:NO
                                                                 andLogoutTitle:nil];
    }
}

@end
