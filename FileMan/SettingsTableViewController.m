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

@import Firebase;

@interface SettingsTableViewController ()

@property (weak, nonatomic) IBOutlet UILabel *searchEngineLabel;
@property (weak, nonatomic) IBOutlet UITextField *homePageField;
@property (weak, nonatomic) IBOutlet UILabel *defaultTab;
@property (weak, nonatomic) IBOutlet UILabel *mimes;
@property (weak, nonatomic) IBOutlet UILabel *passcodeEnabled;
@property (weak, nonatomic) IBOutlet UILabel *dropboxLabel;
@property (weak, nonatomic) IBOutlet UIImageView *priceTag;
@property (weak, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UITableViewCell *filefyPlusCell;

@end

@implementation SettingsTableViewController

#define kRemoveAdsProductIdentifier @"com.SamiSharaf.Filefy.FilefyPlus"

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _homePageField.delegate = self;
    
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
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"FilefyPlus"]) {
        
        if ([LTHPasscodeViewController doesPasscodeExist]) {
            
            self.passcodeEnabled.text = @"Enabled";
            
        } else {
            
            self.passcodeEnabled.text = @"Disabled";
            
        }
        
        self.priceTag.image = [UIImage imageNamed:@"PricetagGreen"];
        self.price.text = @"Purchased";
        self.price.textColor = [UIColor colorWithRed:105.0/255.0 green:219.0/255.0 blue:49.0/255.0 alpha:1.0];
        
        self.filefyPlusCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    } else {
        
        self.passcodeEnabled.text = @"Requires Filefy Plus";
        [[LTHPasscodeViewController sharedUser] setAllowUnlockWithTouchID:NO];
        [LTHPasscodeViewController deletePasscode];
        
        self.priceTag.image = [UIImage imageNamed:@"PricetagBlue"];
        self.price.text = @"1.99USD";
        self.price.textColor = [UIColor colorWithRed:30.0/255.0 green:177.0/255.0 blue:252.0/255.0 alpha:1.0];
        
        self.filefyPlusCell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
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
            
            actionSheet.view.tintColor = [UIColor colorWithRed:30.0/255.0 green:177.0/255.0 blue:252.0/255.0 alpha:1.0];
            
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
            
            actionSheet.view.tintColor = [UIColor colorWithRed:30.0/255.0 green:177.0/255.0 blue:252.0/255.0 alpha:1.0];
            
            [self presentViewController:actionSheet animated:YES completion:nil];
            
        }
        
    } else if (indexPath.section == 6) {
        
        if (indexPath.row == 0) {
            
            [FIRAnalytics logEventWithName:@"Rate_App" parameters:nil];
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id1222563596"]];
            
        } else if (indexPath.row == 1) {
            
            [FIRAnalytics logEventWithName:@"Send_Mail" parameters:nil];
            
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
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    } else if (indexPath.section == 0) {
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"FilefyPlus"]) {
            
            [self performSegueWithIdentifier:@"showPasscode" sender:self];
            
        } else {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Filefy Plus" message:@"Passcode Lock is only available with Filefy Plus" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
            
            alert.view.tintColor = [UIColor colorWithRed:30.0/255.0 green:177.0/255.0 blue:252.0/255.0 alpha:1.0];
            
            [alert addAction:action];
            
            [self presentViewController:alert animated:YES completion:nil];
            
        }
        
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
            
            actionSheet.view.tintColor = [UIColor colorWithRed:30.0/255.0 green:177.0/255.0 blue:252.0/255.0 alpha:1.0];
            
            [actionSheet addAction:cancelAction];
            [actionSheet addAction:action];
            
            [self presentViewController:actionSheet animated:YES completion:nil];
            
        } else {
            
            [DBClientsManager authorizeFromController:[UIApplication sharedApplication]
                                           controller:self
                                              openURL:^(NSURL *url) {
                                                  [[UIApplication sharedApplication] openURL:url];
                                              }
                                          browserAuth:YES];
            
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    } else if (indexPath.section == 5) {
        
        if (indexPath.row == 0) {
            
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"FilefyPlus"]) {
                
                NSLog(@"User requests Filefy Plus");
                
                if([SKPaymentQueue canMakePayments]){
                    NSLog(@"User can make payments");
                    
                    //If you have more than one in-app purchase, and would like
                    //to have the user purchase a different product, simply define
                    //another function and replace kRemoveAdsProductIdentifier with
                    //the identifier for the other product
                    
                    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:kRemoveAdsProductIdentifier]];
                    productsRequest.delegate = self;
                    [productsRequest start];
                    
                }
                else{
                    NSLog(@"User cannot make payments due to parental controls");
                    //this is called the user cannot make payments, most likely due to parental controls
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot Purchase Filefy Plus" message:@"You cannot purchase Filefy Plus probably due to parental control restriction." preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
                    
                    alert.view.tintColor = [UIColor colorWithRed:30.0/255.0 green:177.0/255.0 blue:252.0/255.0 alpha:1.0];
                    
                    [alert addAction:action];
                    
                    [self presentViewController:alert animated:YES completion:nil];
                    
                }
                
            } else {
                
                NSLog(@"Filefy Plus already Purchased");
                
            }
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
        } else if (indexPath.row == 1) {
            
            //this is called when the user restores purchases, you should hook this up to a button
            [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
            [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
        }
        
    }
    
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    SKProduct *validProduct = nil;
    int count = [response.products count];
    if(count > 0){
        validProduct = [response.products objectAtIndex:0];
        NSLog(@"Products Available!");
        [self purchase:validProduct];
    }
    else if(!validProduct){
        NSLog(@"No products available");
        //this is called if your product id is not valid, this shouldn't be called unless that happens.
    }
}

- (void)purchase:(SKProduct *)product{
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    
    if (queue.transactions.count == 0) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"There was a problem purchasing / restoring Filefy Plus" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
        
        alert.view.tintColor = [UIColor colorWithRed:30.0/255.0 green:177.0/255.0 blue:252.0/255.0 alpha:1.0];
        
        [alert addAction:action];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    
    NSLog(@"received restored transactions: %i", queue.transactions.count);
    for(SKPaymentTransaction *transaction in queue.transactions){
        if(transaction.transactionState == SKPaymentTransactionStateRestored){
            //called when the user successfully restores a purchase
            NSLog(@"Transaction state -> Restored");
            
            //if you have more than one in-app purchase product,
            //you restore the correct product for the identifier.
            //For example, you could use
            //if(productID == kRemoveAdsProductIdentifier)
            //to get the product identifier for the
            //restored purchases, you can use
            //
            //NSString *productID = transaction.payment.productIdentifier;
            [self enableFilefyPro];
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    for(SKPaymentTransaction *transaction in transactions){
        //if you have multiple in app purchases in your app,
        //you can get the product identifier of this transaction
        //by using transaction.payment.productIdentifier
        //
        //then, check the identifier against the product IDs
        //that you have defined to check which product the user
        //just purchased
        
        if (transaction.transactionState == SKPaymentTransactionStatePurchasing) {
            
            NSLog(@"Transaction state -> Purchasing");
            //called when the user is in the process of purchasing, do not add any of your own code here.
            
        } else if (transaction.transactionState == SKPaymentTransactionStatePurchased) {
            
            //this is called when the user has successfully purchased the package (Cha-Ching!)
            [self enableFilefyPro]; //you can add your code for what you want to happen when the user buys the purchase here, for this tutorial we use removing ads
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            NSLog(@"Transaction state -> Purchased");
            
        } else if (transaction.transactionState == SKPaymentTransactionStateRestored) {
            
            NSLog(@"Transaction state -> Restored");
            //add the same code as you did from SKPaymentTransactionStatePurchased here
            [self enableFilefyPro];
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Purchase restored" message:@"Your Filefy Plus purchase was restored successfully" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
            
            alert.view.tintColor = [UIColor colorWithRed:30.0/255.0 green:177.0/255.0 blue:252.0/255.0 alpha:1.0];
            
            [alert addAction:action];
            
            [self presentViewController:alert animated:YES completion:nil];
            
        } else if (transaction.transactionState == SKPaymentTransactionStateFailed) {
            
            //called when the transaction does not finish
            if(transaction.error.code == SKErrorPaymentCancelled){
                NSLog(@"Transaction state -> Cancelled");
                //the user cancelled the payment ;(
            } else {
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"There was a problem purchasing / restoring Filefy Plus" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
                
                alert.view.tintColor = [UIColor colorWithRed:30.0/255.0 green:177.0/255.0 blue:252.0/255.0 alpha:1.0];
                
                [alert addAction:action];
                
                [self presentViewController:alert animated:YES completion:nil];
                
            }
            
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            
        }
        
    }
}

-(void)enableFilefyPro {
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FilefyPlus"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"FilefyPlus"]) {
        
        if ([LTHPasscodeViewController doesPasscodeExist]) {
            
            self.passcodeEnabled.text = @"Enabled";
            
        } else {
            
            self.passcodeEnabled.text = @"Disabled";
            
        }
        
        self.priceTag.image = [UIImage imageNamed:@"PricetagGreen"];
        self.price.text = @"Purchased";
        self.price.textColor = [UIColor colorWithRed:105.0/255.0 green:219.0/255.0 blue:49.0/255.0 alpha:1.0];
        
        self.filefyPlusCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    } else {
        
        self.passcodeEnabled.text = @"Requires Filefy Plus";
        [[LTHPasscodeViewController sharedUser] setAllowUnlockWithTouchID:NO];
        [LTHPasscodeViewController deletePasscode];
        
        self.priceTag.image = [UIImage imageNamed:@"PricetagBlue"];
        self.price.text = @"1.99USD";
        self.price.textColor = [UIColor colorWithRed:30.0/255.0 green:177.0/255.0 blue:252.0/255.0 alpha:1.0];
        
        self.filefyPlusCell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
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
    
}

-(void)clearCache {
    
    // Clear Cache.
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    [FIRAnalytics logEventWithName:@"Clear_Cache" parameters:nil];
    
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
    
    [FIRAnalytics logEventWithName:@"Dina" parameters:nil];
    
    SLComposeViewController *tweetSheet = [[SLComposeViewController alloc] init];
    
    tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [tweetSheet setInitialText:@"Filefy is an advanced file manager and downloader for iOS, Get it here: http://bit.ly/Filefy"];
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
