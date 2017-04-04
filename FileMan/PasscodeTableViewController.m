//
//  PasscodeTableViewController.m
//  FileMan
//
//  Created by Sami Sharaf on 3/6/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import "PasscodeTableViewController.h"

@interface PasscodeTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *passcode;

@end

@implementation PasscodeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

+(instancetype)sharedInstance {
    
    static PasscodeTableViewController *sharedInstanceVC = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,^{
        
        sharedInstanceVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"enterPasscodeVC"];
        
    });
    
    return sharedInstanceVC;
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.passcode.text = @"";
    
}

-(IBAction)done:(id)sender {
    
    NSString *pass = [[NSUserDefaults standardUserDefaults] objectForKey:@"passcode"];
    
    if ([self.passcode.text isEqualToString:pass]) {
        
        if (self.purpose == 1) {
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
        } else if (self.purpose == 2) {
            
            [self performSegueWithIdentifier:@"changePassSegue" sender:self];
            
        }
        
    } else {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Wrong Passcode" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
        
        alert.view.tintColor = [UIColor colorWithRed:30.0/255.0 green:177.0/255.0 blue:252.0/255.0 alpha:1.0];
        
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    
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
