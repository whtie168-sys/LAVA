//
//  LaWebviewVC.m
//  WildFireChat
//
//  Created by Ruby on 1/15/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

#import "LaWebviewVC.h"

@interface LaWebviewVC ()<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation LaWebviewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _webView.delegate = self;
    _webView.opaque = NO;
    _webView.backgroundColor = UIColor.clearColor;
    _webView.scrollView.userInteractionEnabled = YES;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = LLLLLL(@"Loading");
    [hud showAnimated:YES];
    
    [self updateADFLanguage];
}

// 0  LAVA官网    1 使用帮助  2 用户服务协议  3 隐私协议  4 法律申明
- (void)updateADFLanguage {
    if (_type == 0) {
        self.navigationItem.title = LLLLLL(@"OfficialWebsite");
        [_webView loadRequest:[NSURLRequest requestWithURL:URL(LLLLLL(@"OFFICIAL_WEBSITE"))]];
    }else if (_type == 1) {
        self.navigationItem.title = LLLLLL(@"UseHelp");
        [_webView loadRequest:[NSURLRequest requestWithURL:URL(@"http://wolava.bot:8080/xy/faq.html")]];
    }else if (_type == 2) {
        self.navigationItem.title = LLLLLL(@"UserAgreement");
        [_webView loadRequest:[NSURLRequest requestWithURL:URL(@"http://wolava.bot:8080/xy/user.html")]];
    }else if (_type == 3) {
        self.navigationItem.title = LLLLLL(@"PrivacyPolicy");
        [_webView loadRequest:[NSURLRequest requestWithURL:URL(@"http://wolava.bot:8080/xy/private.html")]];
    }else if (_type == 4) {
        self.navigationItem.title = LLLLLL(@"LegalStatement");
        [_webView loadRequest:[NSURLRequest requestWithURL:URL(@"http://wolava.bot:8080/xy/fl.html")]];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)dealloc {
    [_webView stopLoading];
    [_webView removeFromSuperview];
    _webView = nil;
    
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* arr_cookies = [cookies cookiesForURL:URL(LLLLLL(@"OFFICIAL_WEBSITE"))];
    for (NSHTTPCookie* cookie in arr_cookies) {
        [cookies deleteCookie:cookie];
    }
    NSLog(@"dealloc - %@",NSStringFromClass(self.class));
}

@end
