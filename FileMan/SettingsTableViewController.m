//
//  SettingsTableViewController.m
//  FileMan
//
//  Created by Sami Sharaf on 1/3/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "LTHPasscodeViewController.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>
#import <Crashlytics/Crashlytics.h>
#import <StoreKit/StoreKit.h>

@import Firebase;

@interface SettingsTableViewController ()

@property (weak, nonatomic) IBOutlet UILabel *searchEngineLabel;
@property (weak, nonatomic) IBOutlet UITextField *homePageField;
@property (weak, nonatomic) IBOutlet UILabel *defaultTab;
@property (weak, nonatomic) IBOutlet UILabel *mimes;
@property (weak, nonatomic) IBOutlet UILabel *passcodeEnabled;
@property (weak, nonatomic) IBOutlet UILabel *dropboxLabel;

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _homePageField.delegate = self;
    
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = YES;
    }
    
    /*
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapReceived)];
    [tapGestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    */
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeDropboxLabel) name:@"dropboxStatusChanged" object:nil];
    
    NSString *homePage = [[NSUserDefaults standardUserDefaults] valueForKey:@"Homepage"];
    _homePageField.text = homePage;
    
    NSString *searchEngine = [[NSUserDefaults standardUserDefaults] valueForKey:@"SearchEngine"];
    
    NSInteger defaultTab = [[NSUserDefaults standardUserDefaults] integerForKey:@"defaultTab"];
    
    if ([searchEngine isEqualToString:@"Google"]) {
        
        _searchEngineLabel.text = @"Google";
        
    } else if ([searchEngine isEqualToString:@"Bing"]) {
        
        _searchEngineLabel.text = @"Bing";
        
    } else if ([searchEngine isEqualToString:@"DuckDuckGo"]) {
        
        _searchEngineLabel.text = @"DuckDuckGo";
        
    }
    
    if ((int)defaultTab == 0) {
        
        self.defaultTab.text = @"Web Browser";
        
    } else if ((int)defaultTab == 1) {
        
        self.defaultTab.text = @"Downloads";
        
    } else if ((int)defaultTab == 2) {
        
        self.defaultTab.text = @"File Manager";
        
    }
    
    if ([LTHPasscodeViewController doesPasscodeExist]) {
        
        self.passcodeEnabled.text = @"Enabled";
        
    } else {
        
        self.passcodeEnabled.text = @"Disabled";
        
    }
    
    if ([[DBClientsManager authorizedClient] isAuthorized]) {
        
        self.dropboxLabel.text = @"Unlink Dropbox";
        
    } else {
        
        self.dropboxLabel.text = @"Link Dropbox";
        
    }
    
    NSArray *mimeTypes = [[NSUserDefaults standardUserDefaults] arrayForKey:@"defaultMIMETypes"];
    
    self.mimes.text = [NSString stringWithFormat:@"%lu", (unsigned long)mimeTypes.count];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"finishedLaunching"]) {
        
        if ([LTHPasscodeViewController doesPasscodeExist]) {
            
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"finishedLaunching"];
            
            if ([LTHPasscodeViewController didPasscodeTimerEnd])
                [[LTHPasscodeViewController sharedUser] showLockScreenWithAnimation:YES
                                                                         withLogout:NO
                                                                     andLogoutTitle:nil];
            
        }
        
    } else {
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"finishedLaunching"];
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.section == 3) {
        
        if (indexPath.row == 0) {
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Are you sure you want to clear all cookies ?"
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction * _Nonnull action) {
                
                // Cancels ActionSheet
                
            }];
            
            UIAlertAction *clearCookies = [UIAlertAction actionWithTitle:@"Clear Cookies" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                
                // Calls function to clear cookies.
                [self clearCookies];
                
            }];
            
            [actionSheet addAction:cancelAction];
            [actionSheet addAction:clearCookies];
            
            actionSheet.popoverPresentationController.sourceView = cell;
            actionSheet.popoverPresentationController.sourceRect = cell.bounds;
            actionSheet.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
            
            [self presentViewController:actionSheet animated:YES completion:nil];
            
        } else if (indexPath.row == 1) {
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Are you sure you want to clear all caches ?"
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction * _Nonnull action) {
                
               // Cancels ActionSheet
                
            }];
            
            UIAlertAction *clearCache = [UIAlertAction actionWithTitle:@"Clear Cache"
                                                                 style:UIAlertActionStyleDestructive
                                                               handler:^(UIAlertAction * _Nonnull action) {
                // Calls function to clear cache.
                [self clearCache];
                
            }];
            
            [actionSheet addAction:cancelAction];
            [actionSheet addAction:clearCache];
            
            actionSheet.popoverPresentationController.sourceView = cell;
            actionSheet.popoverPresentationController.sourceRect = cell.bounds;
            actionSheet.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
            
            [self presentViewController:actionSheet animated:YES completion:nil];
            
        }
        
    } else if (indexPath.section == 1) {
        
        if (indexPath.row == 1) {
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
        }
        
    } else if (indexPath.section == 2) {
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    } else if (indexPath.section == 0) {
        
        [FIRAnalytics logEventWithName:@"Pressed_PasscodeLock" parameters:nil];
        [Answers logCustomEventWithName:@"Pressed_PasscodeLock" customAttributes:nil];
        
        [self performSegueWithIdentifier:@"showPasscode" sender:self];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    } else if (indexPath.section == 4) {
        
        if ([[DBClientsManager authorizedClient] isAuthorized]) {
            
            UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Logout of Dropbox ?" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"Logout" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                
                [DBClientsManager unlinkAndResetClients];
                [self changeDropboxLabel];
                
            }];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction * _Nonnull action) {
                                                                     
                                                                     // Cancels ActionSheet
                                                                     
                                                                 }];
            
            actionSheet.popoverPresentationController.sourceView = cell;
            actionSheet.popoverPresentationController.sourceRect = cell.bounds;
            actionSheet.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
            
            [actionSheet addAction:cancelAction];
            [actionSheet addAction:action];
            
            [self presentViewController:actionSheet animated:YES completion:nil];
            
        } else {
            
            [DBClientsManager authorizeFromController:[UIApplication sharedApplication]
                                           controller:self
                                              openURL:^(NSURL *url) {
                                                  [[UIApplication sharedApplication] openURL:url];
                                              }];
            
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    } else if (indexPath.section == 5) {
        
        if (indexPath.row == 0) {
            
            [FIRAnalytics logEventWithName:@"Rate_App" parameters:nil];
            [Answers logCustomEventWithName:@"Rate_App" customAttributes:nil];
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id1222563596"]];
            
        } else if (indexPath.row == 1) {
            
            [FIRAnalytics logEventWithName:@"Send_Mail" parameters:nil];
            [Answers logCustomEventWithName:@"Send_Mail" customAttributes:nil];
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            // Email Subject
            NSString *emailTitle = @"Filefy";
            // Email Content
            NSString *messageBody = @"";
            // To address
            NSArray *toRecipents = [NSArray arrayWithObject:@"xnightdev@gmail.com"];
            
            MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
            mc.mailComposeDelegate = self;
            [mc setSubject:emailTitle];
            [mc setMessageBody:messageBody isHTML:NO];
            [mc setToRecipients:toRecipents];
            
            // Present mail view controller on screen
            [self presentViewController:mc animated:YES completion:NULL];
            
        }
        
    }
    
}

-(void)clearCookies {
    
    // Clear Cookies.
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        
        [storage deleteCookie:cookie];
        
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"hasURL"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [FIRAnalytics logEventWithName:@"Clear_Coockies" parameters:nil];
    [Answers logCustomEventWithName:@"Clear_Coockies" customAttributes:nil];
    
}

-(void)clearCache {
    
    // Clear Cache.
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    [FIRAnalytics logEventWithName:@"Clear_Cache" parameters:nil];
    [Answers logCustomEventWithName:@"Clear_Cache" customAttributes:nil];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [_homePageField resignFirstResponder];
    
    return YES;
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    
    [[NSUserDefaults standardUserDefaults] setObject:_homePageField.text forKey:@"Homepage"];
    
}

-(void)tapReceived {
    
    [_homePageField resignFirstResponder];
    
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}

-(IBAction)loveMePlz:(id)sender {
    
    FIRCrashLog(@"Dina :3");
    CLS_LOG(@"Dina :3");
    
    [FIRAnalytics logEventWithName:@"Dina" parameters:nil];
    [Answers logCustomEventWithName:@"Dina" customAttributes:nil];
    
    SLComposeViewController *tweetSheet = [[SLComposeViewController alloc] init];
    
    tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [tweetSheet setInitialText:@"Filefy is an Advanced File and Media Manager for iOS, Get it here: http://bit.ly/Filefy"];
    [self presentViewController:tweetSheet animated:YES completion:nil];
    
}

-(void)changeDropboxLabel {
    
    if ([[DBClientsManager authorizedClient] isAuthorized]) {
        
        self.dropboxLabel.text = @"Unlink Dropbox";
        
    } else {
        
        self.dropboxLabel.text = @"Link Dropbox";
        
    }
    
}

- (void)passcodeViewControllerWillClose {
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"finishedLaunching"];
    
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
