//
//  HistoryTableViewController.m
//  FileMan
//
//  Created by Sami Sharaf on 1/2/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import "HistoryTableViewController.h"
#import "HistoryTableViewCell.h"
#import <Crashlytics/Crashlytics.h>

@import Firebase;

@interface HistoryTableViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *clearButton;

@end

@implementation HistoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self reloadData];
    
}

-(void)updateClearButton {
    
    if (titleHistory.count == 0 || titleHistory == nil) {
        
        _clearButton.enabled = NO;
        
    } else {
        
        _clearButton.enabled = YES;
        
    }
    
}

-(IBAction)clearButton:(id)sender {
    
    FIRCrashLog(@"Clearing all history");
    CLS_LOG(@"Clearing all history");
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Are you sure you want to clear all history?" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        // Cancels action sheet.
        
    }];
    
    UIAlertAction *clearAction = [UIAlertAction actionWithTitle:@"Clear History" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        // Calls method to clear history and reload tableView.
        [self clearHistory];
        
    }];
    
    [actionSheet addAction:cancelAction];
    [actionSheet addAction:clearAction];
    
    actionSheet.view.tintColor = [UIColor colorWithRed:30.0/255.0 green:177.0/255.0 blue:252.0/255.0 alpha:1.0];
    
    actionSheet.popoverPresentationController.barButtonItem = self.clearButton;
    actionSheet.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
    
    [self presentViewController:actionSheet animated:YES completion:nil];
    
}

-(void)clearHistory {
    
    [titleHistory removeAllObjects];
    [urlHistory removeAllObjects];
    
    [[NSUserDefaults standardUserDefaults] setObject:titleHistory forKey:@"titleHistory"];
    [[NSUserDefaults standardUserDefaults] setObject:urlHistory forKey:@"urlHistory"];
    
    [self reloadData];
    
    [self.tableView reloadData];
    
}

-(void)reloadData {
    
    titleHistory = [[[NSUserDefaults standardUserDefaults] objectForKey:@"titleHistory"] mutableCopy];
    urlHistory = [[[NSUserDefaults standardUserDefaults] objectForKey:@"urlHistory"] mutableCopy];
    
    [self updateClearButton];
    
}

-(IBAction)doneButton:(id)sender {
    
    FIRCrashLog(@"Done viewing history");
    CLS_LOG(@"Done viewing history");
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"loadBookmark" object:nil];
        
    }];
    
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
    return titleHistory.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HistoryTableViewCell *historyCell = [tableView dequeueReusableCellWithIdentifier:@"historyCell" forIndexPath:indexPath];
    
    if (historyCell == nil) {
        
        historyCell = [[HistoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"historyCell"];
        
    }
    
    historyCell.titleLabel.text = [titleHistory objectAtIndex:indexPath.row];
    historyCell.urlLabel.text = [urlHistory objectAtIndex:indexPath.row];
    
    return historyCell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadBookmark" object:[urlHistory objectAtIndex:indexPath.row]];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        [titleHistory removeObjectAtIndex:indexPath.row];
        [urlHistory removeObjectAtIndex:indexPath.row];
        
        [[NSUserDefaults standardUserDefaults] setObject:titleHistory forKey:@"titleHistory"];
        [[NSUserDefaults standardUserDefaults] setObject:urlHistory forKey:@"urlHistory"];
        
        [self reloadData];
        
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

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
