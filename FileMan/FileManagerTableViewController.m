//
//  FileManagerTableViewController.m
//  FileMan
//
//  Created by Sami Sharaf on 2/5/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import "FileManagerTableViewController.h"
#import "FileManagerTableViewCell.h"
#import "AppDelegate.h"
#import "XFile.h"
#import "XFileParser.h"
#import "XFileParserTest.h"
#import "PDFViewerViewController.h"
#import "TextViewerViewController.h"
#import "EditPropsTableViewController.h"
#import "MusicPlayerViewController.h"
#import "XMusicFile.h"
#import "LTHPasscodeViewController.h"

#import <NAKPlaybackIndicatorView.h>

@import Firebase;

@interface FileManagerTableViewController ()

@property (strong, nonatomic) UISearchController *searchController;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *removeButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *optionsButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *createFolder;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *playerButton;

@property (weak, nonatomic) IBOutlet NAKPlaybackIndicatorView *playbackIndicator;

@end

@implementation FileManagerTableViewController {
    
    AppDelegate *appDelegate;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openFile:) name:@"openFileAtURL" object:nil];
    
    [self.navigationController setToolbarHidden:NO animated:NO];
    
    isBarHidden = NO;
    isEditing = NO;
    
    // Initiate reference to AppDelegate.
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Search controller
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleDefault;
    
    // Add the search bar
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    [self.searchController.searchBar sizeToFit];
    
    [self updateButtons];
    
    UITapGestureRecognizer *tapInditator = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPlayer:)];
    tapInditator.numberOfTapsRequired = 1;
    [self.playbackIndicator addGestureRecognizer:tapInditator];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

-(IBAction)showPlayer:(id)sender {
    
    FIRCrashLog(@"Showing music player");
    
    if (appDelegate.dataRef.hasPlayedOnce) {
        
        MusicPlayerViewController *player = [MusicPlayerViewController sharedInstance];
        [self presentMusicViewController:player];
        
    }
    
}

-(void)presentMusicViewController:(MusicPlayerViewController *)musicViewController {
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:musicViewController];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
    
}

-(void)updateButtons {
    
    if (isEditing) {
        
        self.editButton.title = @"Done";
        self.editButton.style = UIBarButtonItemStyleDone;
        self.removeButton.image = [UIImage imageNamed:@"Delete"];
        self.removeButton.enabled = YES;
        self.optionsButton.image = [UIImage imageNamed:@"List"];
        self.optionsButton.enabled = YES;
        self.createFolder.image = [UIImage imageNamed:@"NewFolder"];
        self.createFolder.enabled = YES;
        self.searchController.searchBar.userInteractionEnabled = NO;
        
    } else {
        
        self.editButton.title = @"Edit";
        self.editButton.style = UIBarButtonItemStylePlain;
        self.removeButton.image = nil;
        self.removeButton.enabled = NO;
        self.optionsButton.image = nil;
        self.optionsButton.enabled = NO;
        self.createFolder.image = nil;
        self.createFolder.enabled = NO;
        self.searchController.searchBar.userInteractionEnabled = YES;
        
    }
    
    if ([self.tableView indexPathsForSelectedRows].count > 0) {
        
        self.removeButton.enabled = YES;
        self.optionsButton.enabled = YES;
        
    } else {
        
        self.removeButton.enabled = NO;
        
        if (appDelegate.dataRef.isMovingItems || appDelegate.dataRef.isCopyingItems) {
            
            self.optionsButton.enabled = YES;
            
        } else {
            
            self.optionsButton.enabled = NO;
            
        }
        
    }
    
    if (appDelegate.dataRef.hasPlayedOnce) {
        
        //self.playerButton.image = [UIImage imageNamed:@"MusicPlayer"];
        self.playerButton.enabled = YES;
        
        if (appDelegate.dataRef.isPlaying) {
            
            self.playbackIndicator.state = NAKPlaybackIndicatorViewStatePlaying;
            
        } else {
            
            self.playbackIndicator.state = NAKPlaybackIndicatorViewStatePaused;
            
        }
        
    } else {
        
        //self.playerButton.image = nil;
        self.playerButton.enabled = NO;
        self.playbackIndicator.state = NAKPlaybackIndicatorViewStateStopped;
        
    }
    
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSString *searchText = searchController.searchBar.text;
    
    if (searchText == nil || [searchText isEqualToString:@""]) {
        
        // If empty the search results are the same as the original data
        self.searchResults = self.files;
        
    } else {
        
        [self filterContentForSearchText:searchText];
        
    }
    
    [self.tableView reloadData];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (isBarHidden) {
        
        [self.navigationController setToolbarHidden:NO animated:YES];
        isBarHidden = NO;
        
    }
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    if (!self.path) {
        
        _path = documentPaths[0];
        self.navigationItem.title = @"File Manager";
        
    } else {
        
        if ([_path isEqual:documentPaths[0]]) {
            
            self.navigationItem.title = @"File Manager";
            
        } else {
            
            NSArray *pathComps = [_path pathComponents];
            NSString *fileName = pathComps[pathComps.count - 1];
            
            self.navigationItem.title = fileName;
            
        }
        
    }
    
    NSLog(@"Number of files: %i", [self filesNumber:documentPaths[0]]);
    
    [self loadFiles];
    [self updateButtons];
    
}

-(int)filesNumber:(NSString *)folderPath {
    
    NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
    NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
    NSString *fileName;
    int files = 0;
    
    while (fileName = [filesEnumerator nextObject]) {
        
        files++;
        
    }
    
    return files;
    
}

-(void)loadFiles {
    
    self.files = [[appDelegate XFileParser] filesInDirectory:self.path];
    
    //XFileParserTest *parserTest = [[XFileParserTest alloc] init];
    //[parserTest logXFileObjectsDetailsFromArray:_files];
    
    [self.tableView reloadData];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBar.translucent = YES;
    
    isCurrentView = YES;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"finishedLaunching"]) {
        
        if ([LTHPasscodeViewController doesPasscodeExist]) {
            
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"finishedLaunching"];
            
            if ([LTHPasscodeViewController didPasscodeTimerEnd])
                [[LTHPasscodeViewController sharedUser] showLockScreenWithAnimation:YES
                                                                         withLogout:NO
                                                                     andLogoutTitle:nil];
            
        }
        
    } else {
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"finishedLaunching"];
        
    }
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    isBarHidden = YES;
    
    isCurrentView = NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *)cellImageForType:(NSString *)type {
    
    NSString *image;
    
    if ([type isEqual:@"directory"]) {
        
        image = @"Folder";
        
    } else if ([type isEqual:@"image"]) {
        
        image = @"Image";
        
    } else if ([type isEqual:@"video"]) {
        
        image = @"Video";
        
    } else if ([type isEqual:@"audio"]) {
        
        image = @"Audio";
        
    } else if ([type isEqual:@"pdf"]) {
        
        image = @"Pdf";
        
    } else if ([type isEqual:@"archive"]) {
        
        image = @"Archive";
        
    } else if ([type isEqual:@"txt"]) {
        
        image = @"Txt";
        
    } else if ([type isEqual:@"disk image"]) {
        
        image = @"Dmg";
        
    } else if ([type isEqual:@"json"]) {
        
        image = @"Json";
        
    } else {
        
        image = @"File";
        
    }
    
    return image;
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.searchController.active) {
        
        return self.searchResults.count;
        
    } else {
        
        return self.files.count;
        
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FileManagerTableViewCell *fileCell = [self.tableView dequeueReusableCellWithIdentifier:@"fileCell" forIndexPath:indexPath];
    
    if (fileCell == nil) {
        
        fileCell = [[FileManagerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"fileCell"];
        
    }
    
    XFile *file;
    
    if (self.searchController.active) {
        
        file = [self.searchResults objectAtIndex:indexPath.row];
        
    } else {
        
        file = [self.files objectAtIndex:indexPath.row];
        
    }
    
    if (file.isDirectory) {
        
        fileCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        
    } else {
        
        fileCell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        
    }
    
    fileCell.displayName.text = file.displayName;
    fileCell.displayImage.image = [UIImage imageNamed:[self cellImageForType:file.fileType]];
    fileCell.displaySize.text = file.fileSize;
    
    return fileCell;
    
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.tableView.isEditing) {
        
        [self.editingArray removeObject:self.files[indexPath.row]];
        
        [self updateButtons];
        
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    XFile *selectedFile;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"FilefyPlus"] || [self filesNumber:documentPaths[0]] < 8) {
        
        if (self.tableView.isEditing) {
            
            [self.editingArray addObject:self.files[indexPath.row]];
            
            [self updateButtons];
            
        } else {
            
            
            if (self.searchController.active) {
                
                selectedFile = self.searchResults[indexPath.row];
                
            } else {
                
                selectedFile = self.files[indexPath.row];
                
            }
            
            if (selectedFile.isDirectory) {
                
                FileManagerTableViewController *fmtvc = [self.storyboard instantiateViewControllerWithIdentifier:@"fileManagerViewController"];
                fmtvc.path = selectedFile.filePath;
                [self.navigationController pushViewController:fmtvc animated:YES];
                
            } else {
                
                if ([selectedFile.fileType isEqual:@"pdf"]) {
                    
                    [self performSegueWithIdentifier:@"pdfViewerSegue" sender:self];
                    
                } else if ([selectedFile.fileType isEqual:@"txt"] || [selectedFile.fileType isEqual:@"json"]) {
                    
                    [self performSegueWithIdentifier:@"textViewerSegue" sender:self];
                    
                } else if ([selectedFile.fileType isEqual:@"video"]) {
                    
                    NSURL *videoURL = [NSURL fileURLWithPath:selectedFile.filePath];
                    MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
                    
                    [self presentMoviePlayerViewControllerAnimated:moviePlayer];
                    [moviePlayer.moviePlayer play];
                    
                } else if ([selectedFile.fileType isEqual:@"audio"]) {
                    
                    MusicPlayerViewController *musicVC = [MusicPlayerViewController sharedInstance];
                    
                    if (self.searchController.active) {
                        
                        self.musicFiles = [[NSMutableArray alloc] init];
                        self.musicIndex = [[NSMutableArray alloc] init];
                        
                        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
                        hud.label.text = @"Loading...";
                        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                            // Do something...
                            
                            for (int i = 0; i < self.searchResults.count; i++) {
                                
                                XFile *file = self.searchResults[i];
                                
                                if ([file.fileType isEqual:@"audio"]) {
                                    
                                    XMusicFile *musicFile = [[XMusicFile alloc] initWithPath:[NSURL fileURLWithPath:file.filePath]];
                                    
                                    [self.musicFiles addObject:musicFile];
                                    [self.musicIndex addObject:file];
                                    
                                }
                                
                            }
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [hud hideAnimated:YES];
                                musicVC.musicFiles = self.musicFiles;
                                musicVC.index = (NSUInteger *)[self.musicIndex indexOfObject:selectedFile];
                                musicVC.fromSelection = YES;
                                
                                [self presentMusicViewController:musicVC];
                                
                                appDelegate.dataRef.hasPlayedOnce = YES;
                                [self updateButtons];
                            });
                        });

                        
                    } else {
                        
                        self.musicFiles = [[NSMutableArray alloc] init];
                        self.musicIndex = [[NSMutableArray alloc] init];
                        
                        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
                        hud.label.text = @"Loading...";
                        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                            // Do something...
                            
                            for (int i = 0; i < self.files.count; i++) {
                                
                                XFile *file = self.files[i];
                                
                                if ([file.fileType isEqual:@"audio"]) {
                                    
                                    XMusicFile *musicFile = [[XMusicFile alloc] initWithPath:[NSURL fileURLWithPath:file.filePath]];
                                    
                                    [self.musicFiles addObject:musicFile];
                                    [self.musicIndex addObject:file];
                                    
                                }
                                
                            }
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [hud hideAnimated:YES];
                                musicVC.musicFiles = self.musicFiles;
                                musicVC.index = (NSUInteger *)[self.musicIndex indexOfObject:selectedFile];
                                musicVC.fromSelection = YES;
                                
                                [self presentMusicViewController:musicVC];
                                
                                appDelegate.dataRef.hasPlayedOnce = YES;
                                [self updateButtons];
                            });
                        });
                        
                    }
                    
                } else if ([selectedFile.fileType isEqual:@"image"]) {
                    
                    MWPhotoBrowser *photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
                    
                    photoBrowser.displayNavArrows = YES;
                    
                    if (self.searchController.active) {
                        
                        self.photoFiles = [[NSMutableArray alloc] init];
                        self.photoIndex = [[NSMutableArray alloc] init];
                        
                        for (int i = 0; i < self.searchResults.count; i++) {
                            
                            XFile *file = self.searchResults[i];
                            
                            if ([file.fileType isEqual:@"image"]) {
                                
                                [self.photoFiles addObject:[MWPhoto photoWithURL:[NSURL fileURLWithPath:file.filePath]]];
                                [self.photoIndex addObject:file];
                                
                            }
                            
                        }
                        
                    } else {
                        
                        self.photoFiles = [[NSMutableArray alloc] init];
                        self.photoIndex = [[NSMutableArray alloc] init];
                        
                        for (int i = 0; i < self.files.count; i++) {
                            
                            XFile *file = self.files[i];
                            
                            if ([file.fileType isEqual:@"image"]) {
                                
                                [self.photoFiles addObject:[MWPhoto photoWithURL:[NSURL fileURLWithPath:file.filePath]]];
                                [self.photoIndex addObject:file];
                                
                            }
                            
                        }
                        
                    }
                    
                    [photoBrowser setCurrentPhotoIndex:[self.photoIndex indexOfObject:selectedFile]];
                    
                    photoBrowser.hidesBottomBarWhenPushed = YES;
                    
                    [self.navigationController setToolbarHidden:YES];
                    isBarHidden = YES;
                    
                    [self.navigationController pushViewController:photoBrowser animated:YES];
                    
                } else if ([selectedFile.fileType isEqual:@"archive"]) {
                    
                    if ([[selectedFile.filePath.lowercaseString pathExtension] isEqualToString:@"zip"]) {
                        
                        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
                        hud.mode = MBProgressHUDModeIndeterminate;
                        hud.label.text = @"Extracting...";
                        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                            // Do something...
                            
                            NSString *fileName = [selectedFile.displayName stringByDeletingPathExtension];
                            NSLog(@"FileName: %@", fileName);
                            
                            if ([SSZipArchive unzipFileAtPath:selectedFile.filePath toDestination:[NSString stringWithFormat:@"%@/%@", self.path, fileName]]) {
                                
                                [self loadFiles];
                                
                            }
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [MBProgressHUD hideHUDForView:self.view animated:YES];
                            });
                        });
                        
                    } else if ([[selectedFile.filePath.lowercaseString pathExtension] isEqualToString:@"rar"]) {
                        
                        NSError *archiveError;
                        URKArchive *archive = [[URKArchive alloc] initWithPath:selectedFile.filePath error:&archiveError];
                        if (archiveError) {
                            
                            NSLog(@"Archive Error: %@", archiveError.localizedDescription);
                            [self errorMessage:@"Archive is invalid"];
                            
                        } else {
                            
                            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
                            hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
                            hud.label.text = @"Extracting...";
                            NSError *error;
                            [archive extractFilesTo:self.path overwrite:NO progress:^(URKFileInfo * _Nonnull currentFile, CGFloat percentArchiveDecompressed) {
                                
                                NSLog(@"Decompressed: %f", percentArchiveDecompressed);
                                hud.progress = percentArchiveDecompressed;
                                
                            } error:&error];
                            
                            if (error) {
                                
                                NSLog(@"Error UnRaring: %@", error);
                                
                            }
                            
                            [hud hideAnimated:YES];
                            [self loadFiles];
                            
                        }
                        
                    }
                    
                }
                
            }
            
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            
        }
        
    } else {
        
        if (self.tableView.isEditing) {
            
            [self.editingArray addObject:self.files[indexPath.row]];
            
            [self updateButtons];
            
        } else {
            
            if (self.searchController.active) {
                
                selectedFile = self.searchResults[indexPath.row];
                
            } else {
                
                selectedFile = self.files[indexPath.row];
                
            }
            
            if (selectedFile.isDirectory) {
                
                FileManagerTableViewController *fmtvc = [self.storyboard instantiateViewControllerWithIdentifier:@"fileManagerViewController"];
                fmtvc.path = selectedFile.filePath;
                [self.navigationController pushViewController:fmtvc animated:YES];
                
            }
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Filefy Plus" message:@"Looks like you have more than 7 files / folders in File Manager! Please consider purchasing Filefy Plus in order to open files, or delete some files first and then open any!" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
            
            alert.view.tintColor = [UIColor colorWithRed:30.0/255.0 green:177.0/255.0 blue:252.0/255.0 alpha:1.0];
            
            [alert addAction:action];
            
            [self presentViewController:alert animated:YES completion:nil];
            
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            
        }
            
        }
    
}

-(NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    
    return self.photoFiles.count;
    
}

-(id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    
    if (index < self.photoFiles.count) {
        
        return [self.photoFiles objectAtIndex:index];
        
    }
    
    return nil;
    
}

-(id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    
    if (index < self.photoFiles.count) {
        
        return [self.photoFiles objectAtIndex:index];
        
    }
    
    return nil;
    
}

-(void)filterContentForSearchText:(NSString *)searchText {
    
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"displayName contains[c] %@", searchText];
    _searchResults = [_files filteredArrayUsingPredicate:resultPredicate];
    
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    scrollOffset = scrollView.contentOffset.y;
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (isCurrentView) {
        
        if (!isEditing) {
            
            if (scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height) {
                
                if (isBarHidden) {
                    
                    [self.navigationController setToolbarHidden:NO animated:YES];
                    isBarHidden = NO;
                    
                }
                
            } else if (scrollView.contentOffset.y > scrollOffset && isBarHidden == NO) {
                
                if (!isBarHidden) {
                    
                    [self.navigationController setToolbarHidden:YES animated:YES];
                    isBarHidden = YES;
                    
                }
                
            } else if (scrollView.contentOffset.y < scrollOffset && isBarHidden == YES) {
                
                if (isBarHidden) {
                    
                    [self.navigationController setToolbarHidden:NO animated:YES];
                    isBarHidden = NO;
                    
                }
                
            }
        }
        
    }
    
}

-(UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 3;
    
}

-(IBAction)editButtonPressed:(id)sender {
    
    [FIRAnalytics logEventWithName:@"Using_File_Editing" parameters:nil];
    
    FIRCrashLog(@"Files editing started");
    
    if (!isEditing) {
        
        isEditing = YES;
        [self updateButtons];
        
        self.editingArray = [[NSMutableArray alloc] init];
        
        [self.tableView setEditing:YES animated:YES];
        
    } else {
        
        isEditing = NO;
        [self updateButtons];
        
        [self.tableView setEditing:NO animated:YES];
        
        self.editingArray = nil;
        
    }
    
}

-(IBAction)deleteSelectedItems:(id)sender {
    
    FIRCrashLog(@"File deletion");
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Are you sure you want to delete selected items?" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        // Cancels action sheet.
        
    }];
    
    UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        for (int i = 0; i < self.editingArray.count; i++) {
            
            XFile *editingFile = self.editingArray[i];
            NSString *filePath = editingFile.filePath;
            
            NSError *error;
            
            if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error]) {
                
                NSLog(@"[Error Deleting]: %@", error);
                [self errorMessage:error.localizedDescription];
                
            }
            
        }
        
        [self.tableView setEditing:NO animated:YES];
        [self loadFiles];
        
        self.editingArray = nil;
        isEditing = NO;
        
        [self updateButtons];
        
    }];
    
    [alert addAction:cancel];
    [alert addAction:delete];
    
    alert.view.tintColor = [UIColor colorWithRed:30.0/255.0 green:177.0/255.0 blue:252.0/255.0 alpha:1.0];
    
    alert.popoverPresentationController.barButtonItem = self.removeButton;
    alert.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(IBAction)optionsPressed:(id)sender {
    
    FIRCrashLog(@"Options List");
    
    NSString *moveActionTitle;
    NSString *copyActionTitle;
    
    if (appDelegate.dataRef.isMovingItems) {
        
        moveActionTitle = @"Paste Cut Items";
        
    } else {
        
        moveActionTitle = @"Cut Items";
        
    }
    
    if ([self.tableView indexPathsForSelectedRows].count > 0) {
        
        copyActionTitle = @"Copy";
        
    } else {
        
        if (appDelegate.dataRef.isCopyingItems) {
            
            copyActionTitle = @"Paste";
            
        } else {
            
            copyActionTitle = @"Copy";
            
        }
        
    }
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        // Cancels action.
        
    }];
    
    UIAlertAction *copyToClipboardAction = [UIAlertAction actionWithTitle:copyActionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self copyToClipboard];
        
    }];
    
    UIAlertAction *moveAction = [UIAlertAction actionWithTitle:moveActionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self copyWithinFileMan];
        
    }];
    
    actionSheet.view.tintColor = [UIColor colorWithRed:30.0/255.0 green:177.0/255.0 blue:252.0/255.0 alpha:1.0];
    
    [actionSheet addAction:cancelAction];
    [actionSheet addAction:copyToClipboardAction];
    [actionSheet addAction:moveAction];
    
    if ([self.tableView indexPathsForSelectedRows].count > 0) {
        
        copyToClipboardAction.enabled = YES;
        
    } else if ([self.tableView indexPathsForSelectedRows].count > 0 == NO && appDelegate.dataRef.isCopyingItems == YES) {
        
        copyToClipboardAction.enabled = YES;
        
    } else if ([self.tableView indexPathsForSelectedRows].count > 0 == NO && appDelegate.dataRef.isCopyingItems == NO) {
        
        copyToClipboardAction.enabled = NO;
        
    }
    
    if ([self.tableView indexPathsForSelectedRows].count > 0) {
        
        moveAction.enabled = YES;
        
    } else if ([self.tableView indexPathsForSelectedRows].count > 0 == NO && appDelegate.dataRef.isMovingItems == YES) {
        
        moveAction.enabled = YES;
        
    } else if ([self.tableView indexPathsForSelectedRows].count > 0 == NO && appDelegate.dataRef.isMovingItems == NO) {
        
        moveAction.enabled = NO;
        
    }
    
    actionSheet.popoverPresentationController.barButtonItem = self.optionsButton;
    actionSheet.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
    
    [self presentViewController:actionSheet animated:YES completion:nil];
    
}

-(void)copyWithinFileMan {
    
    if (appDelegate.dataRef.isMovingItems) {
        
        for (int i = 0; i < appDelegate.dataRef.filesToBeMoved.count; i++) {
            
            XFile *movingFile = appDelegate.dataRef.filesToBeMoved[i];
            NSString *filePath = movingFile.filePath;
            
            NSError *error;
            
            if (![[NSFileManager defaultManager] moveItemAtPath:filePath toPath:[NSString stringWithFormat:@"%@/%@", self.path, movingFile.displayName] error:&error]) {
                
                NSLog(@"[Error Moving]: %@", error.localizedDescription);
                [self errorMessage:error.localizedDescription];
                
            }
            
        }
        
        appDelegate.dataRef.isMovingItems = NO;
        appDelegate.dataRef.filesToBeMoved = nil;
        
        [self.tableView setEditing:NO animated:YES];
        [self loadFiles];
        
    } else {
        
        appDelegate.dataRef.filesToBeMoved = [[NSMutableArray alloc] initWithArray:self.editingArray];
        appDelegate.dataRef.isMovingItems = YES;
        self.editingArray = nil;
        
    }
    
    [self.tableView setEditing:NO animated:YES];
    isEditing = NO;
    
    [self updateButtons];
    
}

-(IBAction)newFolder:(id)sender {
    
    FIRCrashLog(@"New folder");
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"New Folder" message:@"Enter folder name" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        // Cancels action.
        
    }];
    
    UIAlertAction *createAction = [UIAlertAction actionWithTitle:@"Create" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self createNewFolder];
        
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
        textField.placeholder = @"New Folder name";
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        [textField addTarget:self action:@selector(alertTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        
    }];
    
    alert.view.tintColor = [UIColor colorWithRed:30.0/255.0 green:177.0/255.0 blue:252.0/255.0 alpha:1.0];
    
    [alert addAction:cancelAction];
    [alert addAction:createAction];
    
    createAction.enabled = NO;
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(void)copyToClipboard {
    
    if (appDelegate.dataRef.isCopyingItems) {
        
        for (int i = 0; i < appDelegate.dataRef.filesToBeCopied.count; i++) {
            
            XFile *copyingFile = appDelegate.dataRef.filesToBeCopied[i];
            NSString *filePath = copyingFile.filePath;
            
            NSError *error;
            
            if (![[NSFileManager defaultManager] copyItemAtPath:filePath toPath:[NSString stringWithFormat:@"%@/%@", self.path, copyingFile.displayName] error:&error]) {
                
                NSLog(@"[Error Copying]: %@", error);
                [self errorMessage:error.localizedDescription];
                
            }
            
        }
        
        appDelegate.dataRef.isCopyingItems = NO;
        appDelegate.dataRef.filesToBeCopied = nil;
        
        [self.tableView setEditing:NO animated:YES];
        [self loadFiles];
        
    } else {
        
        appDelegate.dataRef.filesToBeCopied = [[NSMutableArray alloc] initWithArray:self.editingArray];
        appDelegate.dataRef.isCopyingItems = YES;
        self.editingArray = nil;
        
    }
    
    [self.tableView setEditing:NO animated:YES];
    isEditing = NO;
    
    [self updateButtons];
    
}

-(void)alertTextFieldDidChange:(UITextField *)sender {
    
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    
    if (alertController) {
        
        UITextField *folder = alertController.textFields.firstObject;
        UIAlertAction *createAction = alertController.actions.lastObject;
        
        createAction.enabled = folder.text.length >= 1;
        
        self.folderName = folder.text;
        
    }
    
}

-(void)createNewFolder {
    
    NSString *newFolderPath = [NSString stringWithFormat:@"%@/%@", self.path, self.folderName];
    
    NSError *error;
    
    if (![[NSFileManager defaultManager] createDirectoryAtPath:newFolderPath withIntermediateDirectories:YES attributes:nil error:&error]) {
        
        NSLog(@"[Error Creating Dir]: %@", error);
        [self errorMessage:error.localizedDescription];
        
    }
    
    [self.tableView setEditing:NO animated:YES];
    [self loadFiles];
    
    isEditing = NO;
    
    [self updateButtons];
    
}

-(void)errorMessage:(NSString *)error {
    
    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Error" message:error preferredStyle:UIAlertControllerStyleAlert];
    
    errorAlert.view.tintColor = [UIColor colorWithRed:30.0/255.0 green:177.0/255.0 blue:252.0/255.0 alpha:1.0];
    
    [self presentViewController:errorAlert animated:YES completion:^{
        
        [self performSelector:@selector(dismissError:) withObject:errorAlert afterDelay:2];
        
    }];
    
}

-(void)dismissError:(UIAlertController *)alert {
    
    [alert dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)openFile:(NSNotification *)notification {
    
    NSURL *url = notification.object;
    NSString *path = url.path;
    
    passedFilePath = nil;
    
    XFile *file = [[XFile alloc] initWithPath:path];
    
    if ([[path lowercaseString].pathExtension isEqual:@"pdf"]) {
        
        passedFilePath = path;
        [self performSegueWithIdentifier:@"openPdfSegue" sender:self];
        
    } else if ([[path lowercaseString].pathExtension isEqual:@"txt"] || [[path lowercaseString].pathExtension isEqual:@"json"]) {
        
        passedFilePath = path;
        [self performSegueWithIdentifier:@"openTextViewerSegue" sender:self];
        
    } else if ([file.fileType isEqual:@"video"]) {
        
        NSURL *videoURL = [NSURL fileURLWithPath:file.filePath];
        MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
        
        [self presentMoviePlayerViewControllerAnimated:moviePlayer];
        [moviePlayer.moviePlayer play];
        
    } else if ([file.fileType isEqual:@"audio"]) {
        
        MusicPlayerViewController *musicVC = [MusicPlayerViewController sharedInstance];
        
        self.musicFiles = [[NSMutableArray alloc] init];
        self.musicIndex = [[NSMutableArray alloc] init];
        
        XMusicFile *musicFile = [[XMusicFile alloc] initWithPath:[NSURL fileURLWithPath:file.filePath]];
        
        [self.musicFiles addObject:musicFile];
        [self.musicIndex addObject:file];
        
        musicVC.musicFiles = self.musicFiles;
        musicVC.index = 0;
        musicVC.fromSelection = YES;
        
        [self presentMusicViewController:musicVC];
        
        appDelegate.dataRef.hasPlayedOnce = YES;
        [self updateButtons];
        
    } else if ([file.fileType isEqual:@"image"]) {
        
        MWPhotoBrowser *photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        
        photoBrowser.enableGrid = NO;
        
        self.photoFiles = [[NSMutableArray alloc] init];
        [self.photoFiles addObject:[MWPhoto photoWithURL:[NSURL fileURLWithPath:path]]];
        
        [photoBrowser setCurrentPhotoIndex:0];
        
        photoBrowser.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController setToolbarHidden:YES];
        isBarHidden = YES;
        
        [self.navigationController pushViewController:photoBrowser animated:YES];
        
    }
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqual:@"EditFileDetailsSegue"]) {
        
        EditPropsTableViewController *editor = [segue destinationViewController];
        
        XFile *selectedFile = self.files[indexPathForAccessoryButton.row];
        
        editor.path = selectedFile.filePath;
        editor.fileTitle = selectedFile.displayName;
        
        [self.navigationController setToolbarHidden:YES animated:YES];
        isBarHidden = YES;
        
    }
    
    if ([segue.identifier isEqual:@"pdfViewerSegue"]) {
        
        PDFViewerViewController *pdfViewer = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        int row = (int)indexPath.row;
        
        XFile *selectedFile = self.files[row];
        
        pdfViewer.pdfURL = [NSURL fileURLWithPath:selectedFile.filePath];
        pdfViewer.pdfTitle = selectedFile.displayName;
        
        [self.navigationController setToolbarHidden:YES animated:YES];
        isBarHidden = YES;
        
    } else if ([segue.identifier isEqual:@"textViewerSegue"]) {
        
        TextViewerViewController *textViewer = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        int row = (int)indexPath.row;
        
        XFile *selectedFile = self.files[row];
        
        textViewer.path = selectedFile.filePath;
        textViewer.title = selectedFile.displayName;
        
        [self.navigationController setToolbarHidden:YES animated:YES];
        isBarHidden = YES;
        
    }
    
    if ([segue.identifier isEqual:@"openPdfSegue"]) {
        
        PDFViewerViewController *pdfViewer = [segue destinationViewController];
        
        XFile *passedFile = [[XFile alloc] initWithPath:passedFilePath];
        
        pdfViewer.pdfURL = [NSURL fileURLWithPath:passedFile.filePath];
        pdfViewer.pdfTitle = passedFile.displayName;
        
        [self.navigationController setToolbarHidden:YES animated:YES];
        isBarHidden = YES;
        
    } else if ([segue.identifier isEqual:@"openTextViewerSegue"]) {
        
        TextViewerViewController *textViewer = [segue destinationViewController];
        
        XFile *passedFile = [[XFile alloc] initWithPath:passedFilePath];
        
        textViewer.path = passedFile.filePath;
        textViewer.title = passedFile.displayName;
        
        [self.navigationController setToolbarHidden:YES animated:YES];
        isBarHidden = YES;
        
    }
    
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    indexPathForAccessoryButton = indexPath;
    [self performSegueWithIdentifier:@"EditFileDetailsSegue" sender:self];
    
}

@end
