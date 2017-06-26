//
//  SearchEngineTableViewController.m
//  FileMan
//
//  Created by Sami Sharaf on 1/7/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import "SearchEngineTableViewController.h"

@interface SearchEngineTableViewController ()

@property (weak, nonatomic) IBOutlet UITableViewCell *googleCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *bingCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *duckDuckGoCell;

@end

@implementation SearchEngineTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *searchEngine = [[NSUserDefaults standardUserDefaults] valueForKey:@"SearchEngine"];
    
    if ([searchEngine isEqualToString:@"Google"]) {
        
        self.googleCell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.bingCell.accessoryType = UITableViewCellAccessoryNone;
        self.duckDuckGoCell.accessoryType = UITableViewCellAccessoryNone;
        
    } else if ([searchEngine isEqualToString:@"Bing"]) {
        
        self.googleCell.accessoryType = UITableViewCellAccessoryNone;
        self.bingCell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.duckDuckGoCell.accessoryType = UITableViewCellAccessoryNone;
        
    } else if ([searchEngine isEqualToString:@"DuckDuckGo"]) {
        
        self.googleCell.accessoryType = UITableViewCellAccessoryNone;
        self.bingCell.accessoryType = UITableViewCellAccessoryNone;
        self.duckDuckGoCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            
            [[NSUserDefaults standardUserDefaults] setValue:@"Google" forKey:@"SearchEngine"];
            self.googleCell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.bingCell.accessoryType = UITableViewCellAccessoryNone;
            self.duckDuckGoCell.accessoryType = UITableViewCellAccessoryNone;
            
        } else if (indexPath.row == 1) {
            
            [[NSUserDefaults standardUserDefaults] setValue:@"Bing" forKey:@"SearchEngine"];
            self.googleCell.accessoryType = UITableViewCellAccessoryNone;
            self.bingCell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.duckDuckGoCell.accessoryType = UITableViewCellAccessoryNone;
            
        } else if (indexPath.row == 2) {
            
            [[NSUserDefaults standardUserDefaults] setValue:@"DuckDuckGo" forKey:@"SearchEngine"];
            self.googleCell.accessoryType = UITableViewCellAccessoryNone;
            self.bingCell.accessoryType = UITableViewCellAccessoryNone;
            self.duckDuckGoCell.accessoryType = UITableViewCellAccessoryCheckmark;
            
        }
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
