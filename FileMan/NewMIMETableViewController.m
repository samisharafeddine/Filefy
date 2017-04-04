//
//  NewMIMETableViewController.m
//  FileMan
//
//  Created by Sami Sharaf on 3/6/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import "NewMIMETableViewController.h"

@import Firebase;

@interface NewMIMETableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *mime;

@end

@implementation NewMIMETableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)cancel:(id)sender {
    
    FIRCrashLog(@"Cancel adding new MIME");
    
    [[NSNotificationCenter defaultCenter] removeObserver:@"newMIME"];
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(IBAction)save:(id)sender {
    
    FIRCrashLog(@"Save new MIME");
    
    if ([self.mime.text isEqualToString:@""] || self.mime.text == nil) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please fill in the required information." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
        
        alert.view.tintColor = [UIColor colorWithRed:30.0/255.0 green:177.0/255.0 blue:252.0/255.0 alpha:1.0];
        
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        
        NSArray *mimeTypes = [[NSUserDefaults standardUserDefaults] arrayForKey:@"defaultMIMETypes"];
        
        NSMutableArray *array = [[NSMutableArray alloc] initWithArray:mimeTypes];
        
        [array addObject:self.mime.text];
        
        [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"defaultMIMETypes"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"newMIME" object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:@"newMIME"];
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    
}

#pragma mark - Table view data source

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
