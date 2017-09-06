//
//  DownloadsTableViewController.m
//  FileMan
//
//  Created by Sami Sharaf on 3/5/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import "DownloadsTableViewController.h"
#import "DownloadsTableViewCell.h"
#import "CompletedDownloadsTableViewCell.h"
#import "TWRDownloadManager.h"
#import "TWRDownloadObject.h"
#import "StartDownloadTableViewController.h"
#import "LTHPasscodeViewController.h"
#import <StoreKit/StoreKit.h>

@interface DownloadsTableViewController ()

@end

@implementation DownloadsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"timesLaunched"] > 3) {
        [SKStoreReviewController requestReview];
    }
    
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = YES;
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadData];
    
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

-(void)reloadData {
    
    completedDownloadsNames = [[NSUserDefaults standardUserDefaults] objectForKey:@"completedDownloadsNames"];
    completedDownloadsURLs = [[NSUserDefaults standardUserDefaults] objectForKey:@"completedDownloadsURLs"];
    completedDownloadsStatuses = [[NSUserDefaults standardUserDefaults] objectForKey:@"completedDownloadsStatuses"];
    currentDownloads = [[TWRDownloadManager sharedManager] currentDownloads];
    
    if (currentDownloads.count == 0 || currentDownloads == nil) {
        
        currentDownloads = @[@"No Active Downloads"];
        
    }
    
    if (completedDownloadsNames.count == 0 || completedDownloadsNames == nil) {
        
        completedDownloadsNames = @[@"No Completed Downloads"];
        
    }
    
    content = @[currentDownloads,
                completedDownloadsNames];
    
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [content[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell...
    
    if (indexPath.section == 0) {
        
        if ([currentDownloads[0] isEqualToString:@"No Active Downloads"]) {
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"emptyDownloadsCell" forIndexPath:indexPath];
            
            if (cell == nil) {
                
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"emptyDownloadsCell"];
                
            }
            
            return cell;
            
        } else {
            
            TWRDownloadObject *download = [[[TWRDownloadManager sharedManager] downloads] objectForKey:[[[TWRDownloadManager sharedManager] currentDownloads] objectAtIndex:indexPath.row]];
            
            DownloadsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"downloadsCell" forIndexPath:indexPath];
            
            if (cell == nil) {
                
                cell = [[DownloadsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"downloadsCell"];
                
            }
            
            cell.name.text = download.fileName;
            download.progressBlock = cell.progressBlock;
            download.completionBlock = cell.completionBlock;
            download.infoBlock = cell.infoBlock;
            
            return cell;
            
        }
        
    } else {
        
        if ([completedDownloadsNames[0] isEqualToString:@"No Completed Downloads"]) {
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"emptyFinishedownloadsCell" forIndexPath:indexPath];
            
            if (cell == nil) {
                
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"emptyFinishedownloadsCell"];
                
            }
            
            return cell;
            
        } else {
            
            CompletedDownloadsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"completedDownloadsCell" forIndexPath:indexPath];
            
            if (cell == nil) {
                
                cell = [[CompletedDownloadsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"completedDownloadsCell"];
                
            }
            
            cell.name.text = completedDownloadsNames[indexPath.row];
            cell.status.text = completedDownloadsStatuses[indexPath.row];
            cell.url.text = completedDownloadsURLs[indexPath.row];
            
            return cell;
            
        }
        
    }
    
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    
    if (indexPath.section == 0) {
        
        if ([currentDownloads[0] isEqualToString:@"No Active Downloads"]) {
            
            return NO;
            
        } else {
            
            DownloadsTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            if (cell.progress.hidden == YES) {
                
                return NO;
                
            } else {
                
                return YES;
                
            }
            
        }
        
    } else {
        
        if ([completedDownloadsNames[0] isEqualToString:@"No Completed Downloads"]) {
            
            return NO;
            
        } else {
            
            return YES;
            
        }
        
    }
    
}

-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        UITableViewRowAction *cancel = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Cancel" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Are you sure you want to cancel this download ?" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil];
            
            UIAlertAction *cancelDownload = [UIAlertAction actionWithTitle:@"Cancel Download" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                
                NSString *identifier = [[[TWRDownloadManager sharedManager] currentDownloads] objectAtIndex:indexPath.row];
                
                [[TWRDownloadManager sharedManager] cancelDownloadForUrl:identifier];
                
                [self performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
                
            }];
            
            DownloadsTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            alert.popoverPresentationController.sourceView = cell;
            alert.popoverPresentationController.sourceRect = cell.bounds;
            alert.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
            
            alert.view.tintColor = [UIColor colorWithRed:30.0/255.0 green:177.0/255.0 blue:252.0/255.0 alpha:1.0];
            
            [alert addAction:cancel];
            [alert addAction:cancelDownload];
            
            [self presentViewController:alert animated:YES completion:nil];
            
        }];
        
        cancel.backgroundColor = [UIColor colorWithRed:253.0/255.0 green:88.0/255.0 blue:48.0/255.0 alpha:1.0];
        
        return @[cancel];
        
    } else {
        
        UITableViewRowAction *start = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Restart" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            
            NSString *urlString = completedDownloadsURLs[indexPath.row];
            
            NSURL *url = [NSURL URLWithString:urlString];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"reloadData" object:nil];
            
            [self downloadFileAtURL:url];
            
            [self reloadData];
            
        }];
        
        start.backgroundColor = [UIColor colorWithRed:105.0/255.0 green:219.0/255.0 blue:49.0/255.0 alpha:1.0];
        
        UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            
            NSMutableArray *downloadsNames = [[NSMutableArray alloc] initWithArray:completedDownloadsNames];
            NSMutableArray *downloadsurls = [[NSMutableArray alloc] initWithArray:completedDownloadsURLs];
            NSMutableArray *downloadsStatuses = [[NSMutableArray alloc] initWithArray:completedDownloadsStatuses];
            
            [downloadsNames removeObjectAtIndex:indexPath.row];
            [downloadsurls removeObjectAtIndex:indexPath.row];
            [downloadsStatuses removeObjectAtIndex:indexPath.row];
            
            [[NSUserDefaults standardUserDefaults] setObject:downloadsNames forKey:@"completedDownloadsNames"];
            [[NSUserDefaults standardUserDefaults] setObject:downloadsurls forKey:@"completedDownloadsURLs"];
            [[NSUserDefaults standardUserDefaults] setObject:downloadsStatuses forKey:@"completedDownloadsStatuses"];
            
            [self reloadData];
            
        }];
        
        delete.backgroundColor = [UIColor colorWithRed:253.0/255.0 green:88.0/255.0 blue:48.0/255.0 alpha:1.0];
        
        UITableViewRowAction *copyLink = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Copy URL" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            
            NSString *urlString = completedDownloadsURLs[indexPath.row];
            
            // Copy link address string.
            UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
            [pasteBoard setString:[NSString stringWithFormat:@"%@", urlString]];
            
            [tableView setEditing:NO animated:YES];
            
        }];
        
        copyLink.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:177.0/255.0 blue:252.0/255.0 alpha:1.0];
        
        return @[delete,
                 copyLink,
                 start];
        
    }
    
}

-(void)downloadFileAtURL:(NSURL *)url {
    
    NSString *fileName = url.lastPathComponent.stringByDeletingPathExtension;
    NSString *extension = url.lastPathComponent.pathExtension;
    
    StartDownloadTableViewController *vc = [StartDownloadTableViewController sharedInstance];
    vc.url = url;
    vc.name = fileName;
    vc.fileExtension = extension;
    
    [self presentDownloadViewController:vc];
    
}

-(void)presentDownloadViewController:(StartDownloadTableViewController *)downloadViewController {
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:downloadViewController];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        return 60.0;
        
    } else {
        
        return 67.0;
        
    }
    
}

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
