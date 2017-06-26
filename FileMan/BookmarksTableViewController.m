//
//  BookmarksTableViewController.m
//  FileMan
//
//  Created by Sami Sharaf on 1/17/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import "AppDelegate.h"
#import "BookmarksTableViewController.h"
#import "BookmarkTableViewCell.h"
#import <Crashlytics/Crashlytics.h>

@import Firebase;

@interface BookmarksTableViewController ()

@end

@implementation BookmarksTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    history = @[@"History"];
    
    [self reloadData];
    
}

-(void)refreshTableViewData {
    
    [self reloadData];
    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"addedBookmark" object:nil];
    
}

-(void)reloadData {
    
    titles = [[[NSUserDefaults standardUserDefaults] objectForKey:@"bookmarkTitles"] mutableCopy];
    urls = [[[NSUserDefaults standardUserDefaults] objectForKey:@"bookmarkURLs"] mutableCopy];
    
    if (titles == nil) {
        
        content = @[history];
        
    } else {
        
        content = @[history,
                    titles];
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (titles == nil) {
        
        return 1;
        
    } else {
        
        return 2;
        
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [content[section] count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell...
    
    BookmarkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bookmarkCell" forIndexPath:indexPath];
    
    if (cell == nil) {
        
        cell = [[BookmarkTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"bookmarkCell"];
        
    }
    
    if (indexPath.section == 0) {
        
        cell.image.image = [UIImage imageNamed:@"History"];
        cell.title.text = @"History";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    } else {
        
        cell.image.image = [UIImage imageNamed:@"Bookmark"];
        cell.title.text = [titles objectAtIndex:indexPath.row];
        
    }
    
    return cell;
    
}

-(IBAction)doneButton:(id)sender {
    
    FIRCrashLog(@"Done viewing bookmarks");
    CLS_LOG(@"Done viewing bookmarks");
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"loadBookmark" object:nil];
        
    }];
    
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    
    if (indexPath.section == 0) {
        
        return NO;
        
    } else {
        
        return YES;
        
    }
    
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        [titles removeObjectAtIndex:indexPath.row];
        [urls removeObjectAtIndex:indexPath.row];
        
        [[NSUserDefaults standardUserDefaults] setObject:titles forKey:@"bookmarkTitles"];
        [[NSUserDefaults standardUserDefaults] setObject:urls forKey:@"bookmarkURLs"];
        
        [self reloadData];
        
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

-(IBAction)addBookmark:(id)sender {
    
    FIRCrashLog(@"Add bookmark pressed");
    CLS_LOG(@"Add bookmark pressed");
    
    //assert(false);
    
    NSString *storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"addBookmarkController"];
    [vc setModalPresentationStyle:UIModalPresentationCustom];
    [vc setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:vc animated:YES completion:^{
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableViewData) name:@"addedBookmark" object:nil];
        
    }];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            
            [self performSegueWithIdentifier:@"HistorySegue" sender:self];
            
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    } else if (indexPath.section == 1) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loadBookmark" object:[urls objectAtIndex:indexPath.row]];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
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
