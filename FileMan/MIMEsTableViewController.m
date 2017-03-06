//
//  MIMEsTableViewController.m
//  FileMan
//
//  Created by Sami Sharaf on 3/6/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import "MIMEsTableViewController.h"
#import "EditMIMETableViewController.h"

@interface MIMEsTableViewController ()

@end

@implementation MIMEsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadData];
    
}

-(void)reloadData {
    
    NSArray *add = @[@"Add new MIME Type"];
    
    mimes = [[NSUserDefaults standardUserDefaults] arrayForKey:@"defaultMIMETypes"];
    
    if (mimes == nil) {
        
        content = @[add];
        
    } else {
        
        content = @[mimes,
                    add];
        
    }
    
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (mimes == nil) {
        
        return 1;
        
    } else {
        
        return 2;
        
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (mimes == nil) {
        
        return 1;
        
    } else {
        
        return [content[section] count];
        
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mimeCell" forIndexPath:indexPath];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"mimeCell"];
        
    }
    
    // Configure the cell...
    
    if (mimes == nil) {
        
        if (indexPath.section == 0) {
            
            cell.textLabel.text = @"Add new MIME Type";
            
        }
        
    } else {
        
        if (indexPath.section == 0) {
            
            cell.textLabel.text = mimes[indexPath.row];
            
        } else if (indexPath.section == 1) {
            
            cell.textLabel.text = @"Add new MIME Type";
            
        }
        
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (mimes == nil) {
        
        if (indexPath.section == 0) {
            
            [self performSegueWithIdentifier:@"newMIME" sender:self];
            
        }
        
    } else {
        
        if (indexPath.section == 0) {
            
            [self performSegueWithIdentifier:@"editMIME" sender:self];
            
        } else {
            
            [self performSegueWithIdentifier:@"newMIME" sender:self];
            
        }
        
    }
    
}

-(void)newMIME:(NSNotification *)notification {
    
    [self reloadData];
    
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    
    if (mimes == nil) {
        
        if (indexPath.section == 0) {
            
            return NO;
            
        }
        
    } else {
        
        if (indexPath.section == 0) {
            
            return YES;
            
        } else {
            
            return NO;
            
        }
        
    }
    
    return NO;
    
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        NSMutableArray *mutableMimes = [[NSMutableArray alloc] initWithArray:mimes];
        
        [mutableMimes removeObjectAtIndex:indexPath.row];
        
        [[NSUserDefaults standardUserDefaults] setObject:mutableMimes forKey:@"defaultMIMETypes"];
        
        [self reloadData];
        
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"newMIME"]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMIME:) name:@"newMIME" object:nil];
        
    } else if ([segue.identifier isEqualToString:@"editMIME"]) {
        
        EditMIMETableViewController *vc = [segue destinationViewController];
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        vc.index = (int)indexPath.row;
        vc.mimeType = mimes[indexPath.row];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMIME:) name:@"newMIME" object:nil];
        
    }
    
}

@end
