//
//  SetPasscodeTableViewController.m
//  FileMan
//
//  Created by Sami Sharaf on 3/6/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import "SetPasscodeTableViewController.h"

@interface SetPasscodeTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *passcode;
@property (weak, nonatomic) IBOutlet UITextField *reEnterPascode;


@end

@implementation SetPasscodeTableViewController

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

-(BOOL)check {
    
    if ([self.passcode.text isEqualToString:@""] || self.passcode.text == nil || [self.reEnterPascode.text isEqualToString:@""] || self.reEnterPascode.text == nil) {
        
        return NO;
        
    } else {
        
        if ([self.passcode.text isEqualToString:self.reEnterPascode.text]) {
            
            return YES;
            
        }
        
        return NO;
        
    }
    
}

-(IBAction)cancel:(id)sender {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}

-(IBAction)done:(id)sender {
    
    if ([self check]) {
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"passcodeLock"];
        [[NSUserDefaults standardUserDefaults] setObject:self.passcode.text forKey:@"passcode"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"setPasscode" object:nil];
        
        [self dismissViewControllerAnimated:YES completion:^{
            
            [[NSNotificationCenter defaultCenter] removeObserver:@"setPasscode"];
            
        }];
        
    } else {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please fill in the required information." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
        
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
        
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
