//
//  AddBTableViewController.m
//  FileMan
//
//  Created by Sami Sharaf on 1/18/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import "AddBTableViewController.h"

@interface AddBTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *bookmarkTitle;
@property (weak, nonatomic) IBOutlet UITextField *bookmarkUrl;

@end

@implementation AddBTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _bookmarkTitle.delegate = self;
    _bookmarkUrl.delegate = self;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self loadBookmarks];
    
}

-(void)loadBookmarks {
    
    titles = [[[NSUserDefaults standardUserDefaults] objectForKey:@"bookmarkTitles"] mutableCopy];
    urls = [[[NSUserDefaults standardUserDefaults] objectForKey:@"bookmarkURLs"] mutableCopy];
    
}

-(void)addBookmark {
    
    [self processUrl:_bookmarkUrl.text];
    
    [titles addObject:_bookmarkTitle.text];
    [urls addObject:url];
    
    [[NSUserDefaults standardUserDefaults] setObject:titles forKey:@"bookmarkTitles"];
    [[NSUserDefaults standardUserDefaults] setObject:urls forKey:@"bookmarkURLs"];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"addedBookmark" object:nil];
        
    }];
    
}

-(void)processUrl:(NSString *)passedURL {
    
    NSURL *enteredURL = [NSURL URLWithString:passedURL];
    
    if (![enteredURL scheme] || [[enteredURL scheme] isEqualToString:@""]) {
        
        enteredURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", passedURL]];
        
    }
    
    if (enteredURL != nil) {
        
        NSLog(@"Entered URL: %@", enteredURL);
        
        url = [NSString stringWithFormat:@"%@", enteredURL];
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)cancelButton:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"addedBookmark" object:nil];
        
    }];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        
        if (indexPath.row == 0) {
            
            if ([_bookmarkTitle.text isEqual:@""] || [_bookmarkUrl.text isEqual:@""]) {
                
                UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please make sure you fill the required fields." preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                    // Cancels alertView.
                    
                }];
                
                [alertView addAction:okAction];
                
                [self presentViewController:alertView animated:YES completion:nil];
                
            } else {
                
                [self addBookmark];
                
            }
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
        }
        
    }
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [_bookmarkUrl resignFirstResponder];
    [_bookmarkTitle resignFirstResponder];
    
    return YES;
    
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
