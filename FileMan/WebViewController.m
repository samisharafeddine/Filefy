//
//  WebViewController.m
//  FileMan
//
//  Created by Sami Sharaf on 12/28/16.
//  Copyright © 2016 Sami Sharaf. All rights reserved.
//

#import "AppDelegate.h"
#import "WebViewController.h"
#import "StartDownloadTableViewController.h"
#import <Crashlytics/Crashlytics.h>

@import Firebase;

@interface WebViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UITextField *urlField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionSheetButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *homeButton;
@property (weak, nonatomic) IBOutlet UIProgressView *loadingProgressView;
@property (weak, nonatomic) IBOutlet UIView *navBarView;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *urlEffect;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *urlFieldWidthConstraint;

@end

@implementation WebViewController {
    
    AppDelegate *appDelegate;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = NO;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    
    [LTHPasscodeViewController sharedUser].delegate = self;
    
    // Initiate reference to AppDelegate.
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    toolbarHidden = NO;
    
    // Delegates.
    self.webView.delegate = self;
    self.urlField.delegate = self;
    self.webView.scrollView.delegate = self;
    self.urlField.delegate = self;
    
    _navBarView.layer.cornerRadius = 5;
    _navBarView.layer.masksToBounds = YES;
    _urlField.layer.cornerRadius = 5;
    _urlEffect.layer.cornerRadius = 5;
    _urlEffect.layer.masksToBounds = YES;
    
    CGRect screenSize = [UIScreen mainScreen].bounds;
    CGFloat screenWidth = screenSize.size.width;
    NSLog(@"Screen Width: %f", screenWidth);
    self.urlFieldWidthConstraint.constant = screenWidth - 22;
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 0)];
    _urlField.leftView = paddingView;
    _urlField.leftViewMode = UITextFieldViewModeAlways;
    
    refresh = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
    [refresh addTarget:self action:@selector(refreshOrStop) forControlEvents:UIControlEventTouchUpInside];
    _urlField.rightView = refresh;
    _urlField.rightViewMode = UITextFieldViewModeUnlessEditing;
    
    _loadingProgressView.progress = 0;
    _loadingProgressView.hidden = YES;
    
    self.urlField.textAlignment = NSTextAlignmentCenter;
    
    [self updateButtons];
    [self updateURLField];
    
    NSString *homePage = [[NSUserDefaults standardUserDefaults] valueForKey:@"Homepage"];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"finishedLaunching"]) {
        
        didEnterPasscode = NO;
        
    }
    
    if (homePage == nil || [homePage isEqual:@""]) {
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"hasURL"] == YES) {
            
            NSString *urlString = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastURL"];
            NSURL *lastUrl = [NSURL URLWithString:urlString];
            NSURLRequest *request = [NSURLRequest requestWithURL:lastUrl];
            
            [self.webView loadRequest:request];
            
        }
        
    } else {
        
        [self urlProcessing:homePage fromHomePageSetting:@"yes"];
        
    }
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecieved)];
    tapGesture.delegate = self;
    [self.webView addGestureRecognizer:tapGesture];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Homepage Button Appearence.
    NSString *homePage = [[NSUserDefaults standardUserDefaults] valueForKey:@"Homepage"];
    
    if (homePage == nil || [homePage isEqual:@""]) {
        
        _homeButton.enabled = NO;
        
    } else {
        
        _homeButton.enabled = YES;
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidLoad:) name:@"AVPlayerItemBecameCurrentNotification" object:nil];
    
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

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVPlayerItemBecameCurrentNotification" object:nil];
    
}

-(void)appWillResignActive:(NSNotification*)note {
    
    [self.webView stopLoading];
    
}
-(void)appWillTerminate:(NSNotification*)note {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    
}

-(void)presentDownloadViewController:(StartDownloadTableViewController *)downloadViewController {
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:downloadViewController];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
    
}

-(void)urlProcessing:(NSString *)passedURL fromHomePageSetting:(NSString *)setting {
    
    NSURL *enteredURL = [NSURL URLWithString:passedURL];
    
    /* for some reason NSURL thinks "example.com:9091" should be "example.com" as the scheme with no host, so fix up first */
    if ([enteredURL host] == nil && [enteredURL scheme] != nil && [enteredURL resourceSpecifier] != nil) {
        
        enteredURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", passedURL]];
        
    }
    
    if (![enteredURL scheme] || [[enteredURL scheme] isEqualToString:@""]) {
        /* no scheme so if it has a space or no dots, assume it's a search query */
        if ([passedURL containsString:@" "] || ![passedURL containsString:@"."]) {
            
            if ([setting isEqual:@"no"]) {
                
                [self initiateSearch:passedURL];
                
            } else if ([setting isEqual:@"yes"]) {
                
                NSString *urlString = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastURL"];
                NSURL *lastUrl = [NSURL URLWithString:urlString];
                NSURLRequest *request = [NSURLRequest requestWithURL:lastUrl];
                
                [self.webView loadRequest:request];
                
            }
            
            enteredURL = nil;
            
        } else {
            
            enteredURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", passedURL]];
            
        }
        
    }
    
    if (enteredURL != nil) {
        
        [self loadRequest:enteredURL];
        
    }
    
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSURLConnection *conn = [NSURLConnection connectionWithRequest:request delegate:self];
    
    if (conn == nil) {
        
        NSLog(@"cannot create connection");
        
    }
    
    return YES;
    
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    [FIRAnalytics logEventWithName:@"load_any_page" parameters:@{@"url":[NSString stringWithFormat:@"%@", [response.URL absoluteString]]}];
    [Answers logCustomEventWithName:@"load_any_page" customAttributes:@{@"url":[NSString stringWithFormat:@"%@", [response.URL absoluteString]]}];
    
    NSLog(@"MIME Type: %@", [response MIMEType]);
    
    NSArray *mimeTypes = [[NSUserDefaults standardUserDefaults] objectForKey:@"defaultMIMETypes"];
    
    for (int i = 0; i < mimeTypes.count; i++) {
        
        NSString *mime = [mimeTypes[i] stringByReplacingOccurrencesOfString:@"*" withString:@""];
        
        if ([response.MIMEType containsString:mime]) {
            
            [self askForDownload:response.URL];
            
        }
        
    }
    
}

-(void)askForDownload:(NSURL *)URL {
    
    NSString *urlString = [NSString stringWithFormat:@"%@", URL];
    
    // REVERSE THIS IF STATEMENT TO MAKE YOUTUBE DOWNLOADING AVAILABLE.
    
    if (![urlString containsString:@"google"]) {
        
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@", URL] message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
            // Cancels action sheet.
            
        }];
        
        UIAlertAction *copyAction = [UIAlertAction actionWithTitle:@"Copy" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            // Copy link address string.
            UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
            [pasteBoard setString:[NSString stringWithFormat:@"%@", URL]];
            
        }];
        
        UIAlertAction *downloadAction = [UIAlertAction actionWithTitle:@"Download" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [self downloadFileAtURL:URL];
            
        }];
        
        [actionSheet addAction:cancelAction];
        [actionSheet addAction:copyAction];
        [actionSheet addAction:downloadAction];
        
        actionSheet.popoverPresentationController.barButtonItem = self.actionSheetButton;
        actionSheet.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
        
        actionSheet.view.tintColor = [UIColor colorWithRed:30.0/255.0 green:177.0/255.0 blue:252.0/255.0 alpha:1.0];
        
        [self presentViewController:actionSheet animated:YES completion:nil];
        
    }
    
}

-(void)downloadFileAtURL:(NSURL *)url {
    
    NSString *fileName = url.lastPathComponent.stringByDeletingPathExtension;
    NSString *extension = url.lastPathComponent.pathExtension;
    
    StartDownloadTableViewController *vc = [StartDownloadTableViewController sharedInstance];
    vc.url = url;
    vc.name = fileName;
    vc.fileExtension = extension;
    
    [self presentDownloadViewController:vc];
    
}

-(void)playerDidLoad:(NSNotification *)notification {
    
    AVPlayerItem *playerItem = [notification object];
    
    if(playerItem == nil) {
        
        return;
        
    } else {
        
        AVURLAsset *asset = (AVURLAsset*)[playerItem asset];
        NSURL *url = [asset URL];
        
        [self askForDownload:url];
        
    }
    
}

-(void)loadBookmark:(NSNotification *)notification {
    
    NSString *passedURL = [notification object];
    
    NSURL *url = [NSURL URLWithString:passedURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [self.webView loadRequest:request];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"loadBookmark" object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    NSLog(@"===========================");
    NSLog(@"= Received Memory Warning =");
    NSLog(@"===========================");
    
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [_urlField setText:[self.webView.request.URL absoluteString]];
    [_urlField performSelector:@selector(selectAll:) withObject:nil afterDelay:0.1];
    
    self.urlField.rightView.hidden = YES;
    
    self.urlField.textAlignment = NSTextAlignmentLeft;
    [self updateButtons];
    self.webView.userInteractionEnabled = NO;
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    
    self.urlField.textAlignment = NSTextAlignmentCenter;
    [self updateURLField];
    [self updateButtons];
    self.webView.userInteractionEnabled = YES;
    self.urlField.rightView.hidden = NO;
    
}

-(void)loadRequest:(NSURL *)url {
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:urlRequest];
    
    [FIRAnalytics logEventWithName:@"Load_Webpage_from_url_field" parameters:@{@"URL":[NSString stringWithFormat:@"%@", [url absoluteString]]}];
    [Answers logCustomEventWithName:@"Load_Webpage_from_url_field" customAttributes:@{@"URL":[NSString stringWithFormat:@"%@", [url absoluteString]]}];
    
}

-(void)updateButtons {
    
    if (self.webView.canGoBack == YES) {
        
        _backButton.enabled = YES;
        
    } else {
        
        _backButton.enabled = NO;
        
    }
    
    if (self.webView.canGoForward == YES) {
        
        _forwardButton.enabled = YES;
        
    } else {
        
        _forwardButton.enabled = NO;
        
    }
    
    if (self.webView.loading == YES) {
        
        [refresh setImage:[UIImage imageNamed:@"Stop"] forState:UIControlStateNormal];
        
    } else {
        
        [refresh setImage:[UIImage imageNamed:@"Refresh"] forState:UIControlStateNormal];
        
    }
    
    if (self.webView.request.URL == NULL) {
        
        _actionSheetButton.enabled = NO;
        
    } else {
        
        _actionSheetButton.enabled = YES;
        
    }
    
}

-(void)webViewDidStartLoad:(UIWebView *)webView {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    _loadingProgressView.progress = 0;
    
    _loadingProgressView.alpha = 0.0f;
    // Then fades it away after 2 seconds (the cross-fade animation will take 0.5s)
    [UIView animateWithDuration:0 delay:0 options:0 animations:^{
        // Animate the alpha value of your imageView from 1.0 to 0.0 here
        _loadingProgressView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        // Once the animation is completed and the alpha has gone to 0.0, hide the view for good
        _loadingProgressView.hidden = NO;
    }];
    
    loadCompleted = NO;
    loadTimer = [NSTimer scheduledTimerWithTimeInterval:0.01667 target:self selector:@selector(updateProgressBar) userInfo:nil repeats:YES];
    [self updateButtons];
    [self updateURLField];
    
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    loadCompleted = YES;
    [self updateButtons];
    [self updateURLField];
    [self updateHistory];
    [self saveLastURL];
    
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    loadCompleted = YES;
    [self updateButtons];
    [self updateURLField];
    
}

-(IBAction)refreshOrStop {
    
    FIRCrashLog(@"Refresh button pressed");
    CLS_LOG(@"Refresh button pressed");
    
    if (self.webView.loading == YES) {
        
        [_webView stopLoading];
        
    } else {
        
        [_webView reload];
        
    }
    
}

-(void)updateHistory {
    
    NSString *webTitle = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    NSArray *oldTitleHistory = [[NSUserDefaults standardUserDefaults] objectForKey:@"titleHistory"];
    NSArray *oldURLHistory = [[NSUserDefaults standardUserDefaults] objectForKey:@"urlHistory"];
    
    NSMutableArray *mutableTitleHistory = [[NSMutableArray alloc] initWithArray:oldTitleHistory];
    NSMutableArray *mutableURLHistory = [[NSMutableArray alloc] initWithArray:oldURLHistory];
    
    // Check if history is not empty.
    
    if (mutableTitleHistory.count == 0 && mutableURLHistory.count == 0) {
        
        [mutableTitleHistory insertObject:webTitle atIndex:0];
        [mutableURLHistory insertObject:[NSString stringWithFormat:@"%@", _webView.request.URL] atIndex:0];
        
        [[NSUserDefaults standardUserDefaults] setObject:mutableTitleHistory forKey:@"titleHistory"];
        [[NSUserDefaults standardUserDefaults] setObject:mutableURLHistory forKey:@"urlHistory"];
        
        
    } else {
        
        if ([[NSString stringWithFormat:@"%@", [mutableTitleHistory objectAtIndex:0]] isEqual:webTitle] && [[NSString stringWithFormat:@"%@", [mutableURLHistory objectAtIndex:0]] isEqual:[NSString stringWithFormat:@"%@", self.webView.request.URL]]) {
            
            
            
        } else {
            
            [mutableTitleHistory insertObject:webTitle atIndex:0];
            [mutableURLHistory insertObject:[NSString stringWithFormat:@"%@", _webView.request.URL] atIndex:0];
            
            [[NSUserDefaults standardUserDefaults] setObject:mutableTitleHistory forKey:@"titleHistory"];
            [[NSUserDefaults standardUserDefaults] setObject:mutableURLHistory forKey:@"urlHistory"];
            
        }
        
    }
    
}

-(IBAction)goBack:(id)sender {
    
    FIRCrashLog(@"GoBack button pressed");
    CLS_LOG(@"GoBack button pressed");
    
    [_webView goBack];
    
}

-(IBAction)goForward:(id)sender {
    
    FIRCrashLog(@"GoForward Button pressed");
    CLS_LOG(@"GoForward Button pressed");
    
    [_webView goForward];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [_urlField resignFirstResponder];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self urlProcessing:_urlField.text fromHomePageSetting:@"no"];
    self.urlField.rightView.hidden = NO;
    [_urlField resignFirstResponder];
    
    return YES;
    
}

-(void)updateURLField {
    
    NSString *host;
    if (self.webView.request.URL == nil) {
        
        host = @"";
        
    } else {
        
        host = [self.webView.request.URL host];
        
        if (host == nil) {
            
            host = [self.webView.request.URL absoluteString];
            
        }
        
    }
    
    NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:@"^www\\d*\\." options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *hostStringOnly = [regEx stringByReplacingMatchesInString:host options:0 range:NSMakeRange(0, [host length]) withTemplate:@""];
    
    // Never mess with the url field if it is in editing mode.
    if (![_urlField isFirstResponder]) {
        
        [_urlField setText:hostStringOnly];
        
    }
    
    if ([self.urlField.text isEqualToString:@""] || self.urlField.text == nil) {
        
        refresh.hidden = YES;
        
    } else {
        
        refresh.hidden = NO;
        
    }
    
    /*
     
     // Old method to color URLTextField
     
    if ([_urlField.text  isEqual: @""] || _urlField == nil) {
        
        _urlField.backgroundColor = [UIColor colorWithRed:237 green:237 blue:237 alpha:1];
        
    } else {
        
        _urlField.backgroundColor = [UIColor clearColor];
        
    }
     */
    
}

-(IBAction)actionSheetPopup:(id)sender {
    
    FIRCrashLog(@"Action Sheet from web view controller");
    CLS_LOG(@"Action Sheet from web view controller");
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@", self.webView.request.URL] message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        // Alert action will automatically dismiss the view.
        
    }];
    
    UIAlertAction *copyLink = [UIAlertAction actionWithTitle:@"Copy Link Address" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        // Copy link address string.
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        [pasteBoard setString:[NSString stringWithFormat:@"%@", self.webView.request.URL]];
        
    }];
    
    
    UIAlertAction *openInSafari = [UIAlertAction actionWithTitle:@"Open in Safari" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [[UIApplication sharedApplication] openURL:self.webView.request.URL];
        
    }];
    
    UIAlertAction *addBookmark = [UIAlertAction actionWithTitle:@"Add to Bookmarks" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self addURLToBookmarks];
        
    }];
    
    [actionSheet addAction:cancelAction];
    [actionSheet addAction:openInSafari];
    [actionSheet addAction:copyLink];
    [actionSheet addAction:addBookmark];
    
    actionSheet.popoverPresentationController.barButtonItem = self.actionSheetButton;
    actionSheet.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
    
    actionSheet.view.tintColor = [UIColor colorWithRed:30.0/255.0 green:177.0/255.0 blue:252.0/255.0 alpha:1.0];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
    
    
}

-(void)saveLastURL {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [NSString stringWithFormat:@"%@", _webView.request.URL];
    [userDefaults setObject:urlString forKey:@"lastURL"];
    
    if ([userDefaults boolForKey:@"hasURL"] == YES) {
        
        // Do nothing.
        
    } else {
        
        [userDefaults setBool:YES forKey:@"hasURL"];
        
    }
    
}

-(void)initiateSearch:(NSString *)searchString {
    
    NSString *currentSearchEngine = [[NSUserDefaults standardUserDefaults] objectForKey:@"SearchEngine"];
    
    NSString *realSearchString = [searchString stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    if ([currentSearchEngine isEqual:@"Google"]) {
        
        NSString *searchURL = [NSString stringWithFormat:@"https://www.google.com/search?q=%@", realSearchString];
        NSURL *url = [NSURL URLWithString:searchURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        [self.webView loadRequest:request];
        
    } else if ([currentSearchEngine isEqual:@"Bing"]) {
        
        NSString *searchURL = [NSString stringWithFormat:@"https://www.bing.com/search?q=%@", realSearchString];
        NSURL *url = [NSURL URLWithString:searchURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        [self.webView loadRequest:request];
        
    } else if ([currentSearchEngine isEqual:@"DuckDuckGo"]) {
        
        NSString *searchURL = [NSString stringWithFormat:@"https://duckduckgo.com/?q=%@", realSearchString];
        NSURL *url = [NSURL URLWithString:searchURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        [self.webView loadRequest:request];
        
    }
    
    [FIRAnalytics logEventWithName:@"Using_Search" parameters:@{@"Search_Engine": currentSearchEngine}];
    [Answers logCustomEventWithName:@"Using_Search" customAttributes:@{@"Search_Engine": currentSearchEngine}];
    
}

-(void)updateProgressBar {
    
    if (loadCompleted == YES) {
        
        if (_loadingProgressView.progress >= 1) {
            
            _loadingProgressView.alpha = 1.0f;
            // Then fades it away after 2 seconds (the cross-fade animation will take 0.5s)
            [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
                // Animate the alpha value of your imageView from 1.0 to 0.0 here
                _loadingProgressView.alpha = 0.0f;
            } completion:^(BOOL finished) {
                // Once the animation is completed and the alpha has gone to 0.0, hide the view for good
                _loadingProgressView.hidden = YES;
            }];
            
            [loadTimer invalidate];
            
        } else {
            
            _loadingProgressView.progress += 0.02;
            
        }
        
    } else {
        
        _loadingProgressView.progress += 0.02;
        
        if (_loadingProgressView.progress >= 0.20) {
            
            _loadingProgressView.progress = 0.20;
            
        }
        
    }
    
}

-(IBAction)showBookmarks:(id)sender {
    
    FIRCrashLog(@"Show bookmarks pressed");
    CLS_LOG(@"Show bookmarks pressed");
    
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"BookmarksController"];
    [vc setModalPresentationStyle:UIModalPresentationCustom];
    [vc setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:vc animated:YES completion:^{
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadBookmark:) name:@"loadBookmark" object:nil];
        
    }];
    
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return YES;
    
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    lastContentOffsetY = scrollView.contentOffset.y;
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height) {
        
        [self.navigationController setToolbarHidden:NO animated:YES];
        toolbarHidden = NO;
        
    } else if (scrollView.contentOffset.y > lastContentOffsetY && toolbarHidden == NO) {
        
        [self.navigationController setToolbarHidden:YES animated:YES];
        toolbarHidden = YES;
        
    } else if (scrollView.contentOffset.y < lastContentOffsetY && toolbarHidden == YES) {
        
        [self.navigationController setToolbarHidden:NO animated:YES];
        toolbarHidden = NO;
        
    }
    
}

-(void)tapRecieved {
    
    if (toolbarHidden == YES) {
        
        [self.navigationController setToolbarHidden:NO animated:YES];
        toolbarHidden = NO;
        
    }
    
}

-(IBAction)homeTapped:(id)sender {
    
    FIRCrashLog(@"Home Tapped in web view controller");
    CLS_LOG(@"Home Tapped in web view controller");
    
    NSString *homePage = [[NSUserDefaults standardUserDefaults] valueForKey:@"Homepage"];
    [self urlProcessing:homePage fromHomePageSetting:@"yes"];
    
}

-(void)addURLToBookmarks {
    
    NSString *webTitle = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSString *webURL = [NSString stringWithFormat:@"%@", self.webView.request.URL];
    
    NSArray *oldBookmarkTitles = [[NSUserDefaults standardUserDefaults] objectForKey:@"bookmarkTitles"];
    NSArray *oldBookmarkURLs = [[NSUserDefaults standardUserDefaults] objectForKey:@"bookmarkURLs"];
    
    NSMutableArray *bookmarkTitles = [[NSMutableArray alloc] initWithArray:oldBookmarkTitles];
    NSMutableArray *bookmarkURLs = [[NSMutableArray alloc] initWithArray:oldBookmarkURLs];
    
    [bookmarkTitles addObject:webTitle];
    [bookmarkURLs addObject:webURL];
    
    [[NSUserDefaults standardUserDefaults] setObject:bookmarkTitles forKey:@"bookmarkTitles"];
    [[NSUserDefaults standardUserDefaults] setObject:bookmarkURLs forKey:@"bookmarkURLs"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UIAlertController *addedAlert = [UIAlertController alertControllerWithTitle:@"Bookmark Added" message:[NSString stringWithFormat:@"'%@' was added succesfully to bookmarks.", webTitle] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        // Cancels action.
        
    }];
    
    [addedAlert addAction:okAction];
    
    addedAlert.view.tintColor = [UIColor colorWithRed:30.0/255.0 green:177.0/255.0 blue:252.0/255.0 alpha:1.0];
    
    [self presentViewController:addedAlert animated:YES completion:nil];
    
}

// LTHPasscodeViewController Delegate

- (void)passcodeWasEnteredSuccessfully {
    
    NSString *homePage = [[NSUserDefaults standardUserDefaults] valueForKey:@"Homepage"];
    
    if (didEnterPasscode == NO) {
        
        if (homePage == nil || [homePage isEqual:@""]) {
            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"hasURL"] == YES) {
                
                NSString *urlString = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastURL"];
                NSURL *lastUrl = [NSURL URLWithString:urlString];
                NSURLRequest *request = [NSURLRequest requestWithURL:lastUrl];
                
                [self.webView loadRequest:request];
                
            }
            
        } else {
            
            [self urlProcessing:homePage fromHomePageSetting:@"yes"];
            
        }
        
    }
    
    didEnterPasscode = YES;
    
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
