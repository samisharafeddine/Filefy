//
//  TextViewerViewController.m
//  FileMan
//
//  Created by Sami Sharaf on 2/8/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import "TextViewerViewController.h"

@import Firebase;

@interface TextViewerViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textViewer;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButtton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;

@end

@implementation TextViewerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.textViewer.delegate = self;
    
    self.navigationItem.title = self.title;
    
    editMode = NO;
    self.editButtton.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.hidesBackButton = YES;
    
    NSError *error;
    
    self.textViewer.text = [NSString stringWithContentsOfFile:self.path encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        
        [self errorMessage:error.localizedDescription];
        NSLog(@"[Error Reading File]: %@", error);
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [FIRAnalytics logEventWithName:@"Using_Text_Viewer" parameters:nil];
    
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController setToolbarHidden:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameWillChange:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetConstraints) name:UIKeyboardDidHideNotification object:nil];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    
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

-(void)updateButtons {
    
    if (editMode) {
        
        self.editButtton.title = @"Done";
        self.editButtton.style = UIBarButtonItemStyleDone;
        
        self.backButton.title = @"Cancel";
        
        self.shareButton.enabled = NO;
        
    } else {
        
        self.editButtton.title = @"Edit";
        self.editButtton.style = UIBarButtonItemStylePlain;
        
        self.backButton.title = @"Back";
        
        self.shareButton.enabled = YES;
        
    }
    
}

-(IBAction)edit:(id)sender {
    
    FIRCrashLog(@"Editing text");
    
    if (!editMode) {
        
        self.textViewer.editable = YES;
        editMode = YES;
        [self updateButtons];
        
    } else {
        
        self.textViewer.editable = NO;
        
        NSError *error;
        
        [self.textViewer.text writeToFile:self.path atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
        if (error) {
            
            [self errorMessage:error.localizedDescription];
            NSLog(@"[Error Writing]: %@", error);
            
        }
        
        editMode = NO;
        [self updateButtons];
        
        self.textViewer.text = [NSString stringWithContentsOfFile:self.path encoding:NSUTF8StringEncoding error:nil];
        
    }
    
}

-(IBAction)back:(id)sender {
    
    FIRCrashLog(@"Going back from text viewer");
    
    if (!editMode) {
        
        [self.navigationController popViewControllerAnimated:YES];
        
    } else {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Are you sure ?" message:@"Are you sure you want to discard changes ?" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
            // Cancels alert.
            
        }];
        
        UIAlertAction *discard = [UIAlertAction actionWithTitle:@"Discard" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            self.textViewer.editable = NO;
            
            editMode = NO;
            [self updateButtons];
            
            self.textViewer.text = [NSString stringWithContentsOfFile:self.path encoding:NSUTF8StringEncoding error:nil];
            
        }];
        
        [alert addAction:cancel];
        [alert addAction:discard];
        
        alert.view.tintColor = [UIColor colorWithRed:30.0/255.0 green:177.0/255.0 blue:252.0/255.0 alpha:1.0];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    
}

-(void)keyboardFrameWillChange:(NSNotification *)notification {
    
    NSDictionary *info = notification.userInfo;
    NSValue *value = info[UIKeyboardFrameEndUserInfoKey];
    
    CGRect rawFrame = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    
    self.bottomConstraint.constant = keyboardFrame.size.height;
    [self updateViewConstraints];
    
}

-(void)resetConstraints {
    
    self.bottomConstraint.constant = 0;
    [self updateViewConstraints];
    
}

-(IBAction)actionPressed:(id)sender {
    
    FIRCrashLog(@"Action button pressed in text viewer");
    
    [FIRAnalytics logEventWithName:@"OpenIn_From_TextViewer" parameters:nil];
    
    UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL fileURLWithPath:self.path]] applicationActivities:nil];
    
    activityView.excludedActivityTypes = @[UIActivityTypeCopyToPasteboard];
    
    [self presentViewController:activityView animated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
