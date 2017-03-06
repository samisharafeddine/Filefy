//
//  DownloadsTableViewController.m
//  FileMan
//
//  Created by Sami Sharaf on 3/5/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import "DownloadsTableViewController.h"
#import "DownloadsTableViewCell.h"
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
    
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[TWRDownloadManager sharedManager] currentDownloads] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell...
    
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
