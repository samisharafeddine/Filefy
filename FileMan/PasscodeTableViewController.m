//
//  PasscodeTableViewController.m
//  Filefy
//
//  Created by Sami Sharaf on 4/6/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import "PasscodeTableViewController.h"

#import <LocalAuthentication/LAContext.h>

@interface PasscodeTableViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *passcodeSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *touchIDSwitch;

@end

@implementation PasscodeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [LTHPasscodeViewController sharedUser].delegate = self;
    
    [self.passcodeSwitch addTarget:self
                      action:@selector(stateChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.touchIDSwitch addTarget:self
                            action:@selector(TIDstateChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self updateView];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)updateView {
    
    if ([LTHPasscodeViewController doesPasscodeExist]) {
        
        [self.passcodeSwitch setOn:YES];
        
        if ([self isTouchIDAvailable]) {
            
            self.touchIDSwitch.enabled = YES;
            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"TouchID"]) {
                
                [self.touchIDSwitch setOn:YES];
                
            } else {
                
                [self.touchIDSwitch setOn:NO];
                
            }
            
        } else {
            
            self.touchIDSwitch.enabled = NO;
            [self.touchIDSwitch setOn:NO];
            
        }
        
    } else {
        
        [self.passcodeSwitch setOn:NO];
        
        if ([self isTouchIDAvailable]) {
            
            self.touchIDSwitch.enabled = NO;
            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"TouchID"]) {
                
                [self.touchIDSwitch setOn:YES];
                
            } else {
                
                [self.touchIDSwitch setOn:NO];
                
            }
            
        } else {
            
            self.touchIDSwitch.enabled = NO;
            [self.touchIDSwitch setOn:NO];
            
        }
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 2) {
        
        if ([LTHPasscodeViewController doesPasscodeExist]) {
            
            [[LTHPasscodeViewController sharedUser] showForChangingPasscodeInViewController:self asModal:YES];
            
        } else {
            
            [self errorMessage:@"Please set a passcode first."];
            
        }
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)stateChanged:(UISwitch *)switchState {
    
    if ([switchState isOn]) {
        
        if (![LTHPasscodeViewController doesPasscodeExist]) {
            
            [[LTHPasscodeViewController sharedUser] showForEnablingPasscodeInViewController:self asModal:YES];
            
        }
        
    } else {
        
        if ([LTHPasscodeViewController doesPasscodeExist]) {
            
            [[LTHPasscodeViewController sharedUser] showForDisablingPasscodeInViewController:self asModal:YES];
            
        }
        
    }
    
}

- (void)TIDstateChanged:(UISwitch *)switchState {
    
    if ([switchState isOn]) {
        
        [[LTHPasscodeViewController sharedUser] setAllowUnlockWithTouchID:YES];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"TouchID"];
        
    } else {
        
        [[LTHPasscodeViewController sharedUser] setAllowUnlockWithTouchID:NO];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"TouchID"];
        
    }
    
}

- (void)passcodeViewControllerWillClose {
    
    [self updateView];
    
}

- (BOOL)isTouchIDAvailable {
    if ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] != NSOrderedAscending) {
        return [[[LAContext alloc] init] canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
    }
    return NO;
}

-(void)errorMessage:(NSString *)error {
    
    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Error" message:error preferredStyle:UIAlertControllerStyleAlert];
    
    [self presentViewController:errorAlert animated:YES completion:^{
        
        [self performSelector:@selector(dismissError:) withObject:errorAlert afterDelay:2];
        
    }];
    
}

-(void)dismissError:(UIAlertController *)alert {
    
    [alert dismissViewControllerAnimated:YES completion:nil];
    
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
