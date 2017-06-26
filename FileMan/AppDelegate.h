//
//  AppDelegate.h
//  FileMan
//
//  Created by Sami Sharaf on 12/28/16.
//  Copyright © 2016 Sami Sharaf. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DataRef.h"
#import "XFileParser.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic , assign) bool blockRotation;

@property (strong, atomic) DataRef *dataRef;
@property (strong, atomic) XFileParser *XFileParser;

@property (nonatomic, copy) void(^backgroundTransferCompletionHandler)();

@end

