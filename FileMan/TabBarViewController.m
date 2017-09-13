//
//  TabBarViewController.m
//  FileMan
//
//  Created by Sami Sharaf on 2/27/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import "TabBarViewController.h"

@interface TabBarViewController ()

@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tabBar.tintColor = [UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchTabsAndSendOpenNotification:) name:@"openFile" object:nil];
    
    self.selectedIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"defaultTab"];
    
}

-(void)switchTabsAndSendOpenNotification:(NSNotification *)notification {
    
    self.selectedIndex = 2;
    
    NSURL *notificationObject = [notification object];
    
    [self performSelector:@selector(sendFileOpenNotification:) withObject:notificationObject afterDelay:2];
    
}

-(void)sendFileOpenNotification:(NSURL *)url {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"openFileAtURL" object:url];
    
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    
    if ([self.tabBar.items indexOfObject:item] == 3) {
        
        self.tabBar.tintColor = [UIColor redColor];
        
    } else {
        
        self.tabBar.tintColor = [UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0];
        
    }
    
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
