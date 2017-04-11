//
//  EditPropsTableViewController.m
//  FileMan
//
//  Created by Sami Sharaf on 2/9/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import "EditPropsTableViewController.h"

#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>

@import Firebase;

@interface EditPropsTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *fileName;
@property (weak, nonatomic) IBOutlet UITextField *fileExtension;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@end

@implementation EditPropsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.fileTitle;
    
    editMode = NO;
    
    [self updateButtons];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self getData];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [FIRAnalytics logEventWithName:@"Using_FileProps_Editing" parameters:nil];
    
    [self.navigationController setToolbarHidden:YES];
    
}

-(void)getData {
    
    self.fileName.enabled = NO;
    self.fileExtension.enabled = NO;
    
    NSString *filename = [self.path lastPathComponent];
    
    self.fileName.text = [filename stringByDeletingPathExtension];
    
    self.fileExtension.text = [self.path pathExtension];
    
}

-(void)updateButtons {
    
    if (editMode) {
        
        self.fileName.enabled = YES;
        self.fileExtension.enabled = YES;
        self.doneButton.title = @"Done";
        self.doneButton.style = UIBarButtonItemStyleDone;
        
    } else {
        
        self.fileName.enabled = NO;
        self.fileExtension.enabled = NO;
        self.doneButton.title = @"Edit";
        self.doneButton.style = UIBarButtonItemStylePlain;
        
    }
    
}

-(IBAction)editPressed:(id)sender {
    
    FIRCrashLog(@"Editing a file props");
    
    if (editMode) {
        
        editMode = NO;
        
        [self updateButtons];
        
        NSString *location = [self.path stringByDeletingLastPathComponent];
        NSString *newFileName = [self.fileName.text stringByAppendingPathExtension:self.fileExtension.text];
        NSString *newPath = [location stringByAppendingPathComponent:newFileName];
        
        NSError *error;
        
        if (![[NSFileManager defaultManager] moveItemAtPath:self.path toPath:newPath error:&error]) {
            
            [self errorMessage:error.localizedDescription];
            NSLog(@"[Error Renaming]: %@", error);
            
        } else {
            
            self.path = newPath;
            
        }
        
        [self getData];
        
    } else {
        
        editMode = YES;
        
        [self updateButtons];
    }
    
}

-(void)errorMessage:(NSString *)error {
    
    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Error" message:error preferredStyle:UIAlertControllerStyleAlert];
    
    errorAlert.view.tintColor = [UIColor colorWithRed:30.0/255.0 green:177.0/255.0 blue:252.0/255.0 alpha:1.0];
    
    [self presentViewController:errorAlert animated:YES completion:^{
        
        [self performSelector:@selector(dismissError:) withObject:errorAlert afterDelay:2];
        
    }];
    
}

-(void)infoMessageWithTitle:(NSString *)title andMessage:(NSString *)message {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    alert.view.tintColor = [UIColor colorWithRed:30.0/255.0 green:177.0/255.0 blue:252.0/255.0 alpha:1.0];
    
    [self presentViewController:alert animated:YES completion:^{
        
        [self performSelector:@selector(dismissError:) withObject:alert afterDelay:2];
        
    }];
    
}

-(void)dismissError:(UIAlertController *)alert {
    
    [alert dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        
        [FIRAnalytics logEventWithName:@"Using_OpenIn_From_FileProps" parameters:nil];
        
        UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL fileURLWithPath:self.path]] applicationActivities:nil];
        
        activityView.excludedActivityTypes = @[UIActivityTypeCopyToPasteboard];
        
        [self presentViewController:activityView animated:YES completion:nil];
        
    } else if (indexPath.section == 2) {
        
        if ([[DBClientsManager authorizedClient] isAuthorized]) {
            
            DBUserClient *client = [DBClientsManager authorizedClient];
            
            NSData *fileData = [[NSFileManager defaultManager] contentsAtPath:self.path];
            
            [[[client.filesRoutes uploadData:[NSString stringWithFormat:@"/%@", [self.path lastPathComponent]] inputData:fileData]
              setResponseBlock:^(DBFILESFileMetadata *result, DBFILESUploadError *routeError, DBRequestError *networkError) {
                  if (result) {
                      NSLog(@"%@\n", result);
                  } else {
                      NSLog(@"%@\n%@\n", routeError, networkError);
                  }
              }] setProgressBlock:^(int64_t bytesUploaded, int64_t totalBytesUploaded, int64_t totalBytesExpectedToUploaded) {
                  NSLog(@"\n%lld\n%lld\n%lld\n", bytesUploaded, totalBytesUploaded, totalBytesExpectedToUploaded);
              }];
            
            [self infoMessageWithTitle:@"Uploading" andMessage:@"File is now being uploaded to Dropbox."];
            
        } else {
            
            [self infoMessageWithTitle:@"Dropbox Not Linked" andMessage:@"You do not have a linked Dropbox account."];
            
        }
        
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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
