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

@interface DownloadsTableViewController ()

@end

@implementation DownloadsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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
            
            CompletedDownloadsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"finishedDownloadsCell" forIndexPath:indexPath];
            
            if (cell == nil) {
                
                cell = [[CompletedDownloadsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"finishedDownloadsCell"];
                
            }
            
            cell.name.text = completedDownloadsNames[indexPath.row];
            cell.status.text = completedDownloadsStatuses[indexPath.row];
            
            return cell;
            
        }
        
    }
    
}

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
