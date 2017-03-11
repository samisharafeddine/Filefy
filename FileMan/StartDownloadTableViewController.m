//
//  StartDownloadTableViewController.m
//  FileMan
//
//  Created by Sami Sharaf on 3/6/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import "StartDownloadTableViewController.h"
#import "TWRDownloadManager.h"

@import Firebase;

@interface StartDownloadTableViewController ()

@end

@implementation StartDownloadTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

+(instancetype)sharedInstance {
    
    static StartDownloadTableViewController *sharedInstanceVC = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,^{
        
        sharedInstanceVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"startDownloadVC"];
        
    });
    
    return sharedInstanceVC;
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.fileName.text = self.name;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)cancel:(id)sender {
    
    FIRCrashLog(@"Canceled starting download");
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        
        NSString *name = [NSString stringWithFormat:@"%@.%@", self.fileName.text, self.fileExtension];
        
        [[TWRDownloadManager sharedManager] downloadFileForURL:[self.url absoluteString] withName:name progressBlock:nil remainingTime:nil completionBlock:nil infoBlock:nil enableBackgroundMode:[[NSUserDefaults standardUserDefaults] boolForKey:@"backgroundDownloads"]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:nil];
        
        [FIRAnalytics logEventWithName:@"Used_Download_Function" parameters:nil];
        
        [self dismissViewControllerAnimated:YES completion:^{
            
            [[NSNotificationCenter defaultCenter] removeObserver:@"reloadData"];
            
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            
        }];
        
    }
    
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
