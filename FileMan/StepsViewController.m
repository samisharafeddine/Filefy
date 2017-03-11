//
//  StepsViewController.m
//  FileMan
//
//  Created by Sami Sharaf on 3/7/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import "StepsViewController.h"
#import "AppDelegate.h"

@import Firebase;

@interface StepsViewController ()

@end

@implementation StepsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    AppDelegate *shared = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    shared.blockRotation = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)myAppIsDope:(id)sender {
    
    FIRCrashLog(@"Tutorial Start Button Pushed");
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasCompletedTutorial"]) {
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasCompletedTutorial"];
        
    }
    
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"RootController"];
    [vc setModalPresentationStyle:UIModalPresentationCustom];
    [vc setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:vc animated:YES completion:^{
        
        AppDelegate *shared = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        shared.blockRotation = NO;
        
    }];
    
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
