//
//  SettingsTableViewController.h
//  FileMan
//
//  Created by Sami Sharaf on 1/3/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <StoreKit/StoreKit.h>

@interface SettingsTableViewController : UITableViewController <UITextFieldDelegate, UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver> {
    
    CGRect rect;
    
}

@end
