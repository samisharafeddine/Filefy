//
//  SettingsTableViewController.m
//  FileMan
//
//  Created by Sami Sharaf on 1/3/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "PasscodeTableViewController.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@import Firebase;

@interface SettingsTableViewController ()

@property (weak, nonatomic) IBOutlet UILabel *searchEngineLabel;
@property (weak, nonatomic) IBOutlet UITextField *homePageField;
@property (weak, nonatomic) IBOutlet UILabel *defaultTab;
@property (weak, nonatomic) IBOutlet UILabel *maxDownloads;
@property (weak, nonatomic) IBOutlet UISwitch *backgroundDownloads;
@property (weak, nonatomic) IBOutlet UILabel *mimes;
@property (weak, nonatomic) IBOutlet UISwitch *backup;
@property (weak, nonatomic) IBOutlet UISwitch *passcode;

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _homePageField.delegate = self;
    
    [self.backgroundDownloads addTarget:self action:@selector(backgroundSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.backup addTarget:self action:@selector(backupSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.passcode addTarget:self action:@selector(passcodeToggleSwitched:) forControlEvents:UIControlEventValueChanged];
    
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
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"backgroundDownloads"]) {
        
        [self.backgroundDownloads setOn:YES animated:NO];
        
    } else {
        
        [self.backgroundDownloads setOn:NO animated:NO];
        
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"backup"]) {
        
        [self.backup setOn:YES animated:NO];
        
    } else {
        
        [self.backup setOn:NO animated:NO];
        
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"passcodeLock"]) {
        
        [self.passcode setOn:YES animated:NO];
        
    } else {
        
        [self.passcode setOn:NO animated:NO];
        
    }
    
    NSInteger maxDownloads = [[NSUserDefaults standardUserDefaults] integerForKey:@"maxDownloads"];
    
    self.maxDownloads.text = [NSString stringWithFormat:@"%ld", (long)maxDownloads];
    
    NSArray *mimeTypes = [[NSUserDefaults standardUserDefaults] arrayForKey:@"defaultMIMETypes"];
    
    self.mimes.text = [NSString stringWithFormat:@"%lu", (unsigned long)mimeTypes.count];
    
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
        
    } else if (indexPath.section == 4) {
        
        if (indexPath.row == 0) {
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id1195660245"]];
            
        } else if (indexPath.row == 1) {
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            // Email Subject
            NSString *emailTitle = @"";
            // Email Content
            NSString *messageBody = @"";
            // To address
            NSArray *toRecipents = [NSArray arrayWithObject:@"samisharafdev@hotmail.com"];
            
            MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
            mc.mailComposeDelegate = self;
            [mc setSubject:emailTitle];
            [mc setMessageBody:messageBody isHTML:NO];
            [mc setToRecipients:toRecipents];
            
            // Present mail view controller on screen
            [self presentViewController:mc animated:YES completion:NULL];
            
        }
        
    } else if (indexPath.section == 1) {
        
        if (indexPath.row == 1) {
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
        }
        
    } else if (indexPath.section == 2) {
        
        if (indexPath.row == 0) {
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
        } else if (indexPath.row == 2) {
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
        } else if (indexPath.row == 3) {
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
        }
        
    } else if (indexPath.section == 0) {
        
        if (indexPath.row == 1) {
            
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"passcodeLock"]) {
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Enable passcode lock and set passcode first." preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
                
                [alert addAction:ok];
                
                [self presentViewController:alert animated:YES completion:nil];
                
            } else {
                
                PasscodeTableViewController *vc = [PasscodeTableViewController sharedInstance];
                
                vc.purpose = 2;
                [self presentPasscodeViewController:vc];
                
            }
            
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            
        }
        
    }
    
}

-(void)presentPasscodeViewController:(PasscodeTableViewController *)passcodeViewController {
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:passcodeViewController];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
    
}

-(void)passcodeToggleSwitched:(UISwitch *)switchState {
    
    if ([switchState isOn]) {
        
        NSString * storyboardName = @"Main";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
        UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"setPasscode"];
        [vc setModalPresentationStyle:UIModalPresentationCustom];
        [vc setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
        [self presentViewController:vc animated:YES completion:^{
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didsetpasscode) name:@"setPasscode" object:nil];
            
        }];
        
    } else {
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"passcodeLock"];
        
    }
    
    [self.passcode setOn:NO animated:YES];
    
}

-(void)didsetpasscode {
    
    [self.passcode setOn:YES animated:YES];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"passcodeLock"];
    
}

-(void)clearCookies {
    
    // Clear Cookies.
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        
        [storage deleteCookie:cookie];
        
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"hasURL"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

-(void)clearCache {
    
    // Clear Cache.
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
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

-(void)backgroundSwitchChanged:(UISwitch *)switchState {
    
    if ([switchState isOn]) {
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"backgroundDownloads"];
        
    } else {
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"backgroundDownloads"];
        
    }
    
}

-(void)backupSwitchChanged:(UISwitch *)switchState {
    
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *docPath = array[0];
    NSURL *docURL = [NSURL fileURLWithPath:docPath];
    
    if ([switchState isOn]) {
        
        if ([self addNoSkipBackupAttributeToItemAtURL:docURL]) {
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"backup"];
            
        } else {
            
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"backup"];
            
            [self.backup setOn:NO animated:YES];
            
        }
        
    } else {
        
        if ([self addSkipBackupAttributeToItemAtURL:docURL]) {
            
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"backup"];
            
        } else {
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"backup"];
            
            [self.backup setOn:YES animated:YES];
            
        }
        
    }
    
}

-(BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL {
    
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue:[NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    
    return success;
    
}

- (BOOL)addNoSkipBackupAttributeToItemAtURL:(NSURL *)URL {
    
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue:[NSNumber numberWithBool: NO]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error including %@ in backup %@", [URL lastPathComponent], error);
    }
    
    return success;
    
}

-(IBAction)loveMePlz:(id)sender {
    
    FIRCrashLog(@"Dina :3");
    
    [FIRAnalytics logEventWithName:@"Dina" parameters:nil];
    
    SLComposeViewController *tweetSheet = [[SLComposeViewController alloc] init];
    
    tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [tweetSheet setInitialText:@"FileMan is an advanced file manager and downloader for iOS, Get it here: http://bit.ly/FileMan"];
    [self presentViewController:tweetSheet animated:YES completion:nil];
    
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
