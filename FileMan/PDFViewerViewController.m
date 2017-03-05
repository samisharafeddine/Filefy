//
//  PDFViewerViewController.m
//  FileMan
//
//  Created by Sami Sharaf on 2/8/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import "PDFViewerViewController.h"

@interface PDFViewerViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *pdfWebView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionButton;

@end

@implementation PDFViewerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = self.pdfTitle;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.pdfURL];
    [self.pdfWebView loadRequest:request];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController setToolbarHidden:YES];
    
}

-(IBAction)actionPressed:(id)sender {
    
    UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:@[self.pdfURL] applicationActivities:nil];
    
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
