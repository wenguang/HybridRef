//
//  ViewController.m
//  HybridRef
//
//  Created by wenguang pan on 2017/3/18.
//  Copyright © 2017年 wenguang pan. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#include <objc/runtime.h>

//#define testurl @"https://www.baidu.com"
#define testurl @"http://h5rsc.vipstatic.com/pea_apps/app/lefeng/beautyVideo/videoList.html"
//加载url空白，why？

@interface ViewController () <WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *wkwebview;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //1、该对象提供了通过js向web view发送消息的途径
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    //添加在js中操作的对象名称，通过该对象来向web view发送消息
    [userContentController addScriptMessageHandler:self name:@"FirstJsObect"];
    
    //2、
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.userContentController = userContentController;
    
    //3、通过初试化方法，生成webview对象并完成配置
    WKWebView *webview = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    webview.UIDelegate = self;
    webview.navigationDelegate = self;
    [self.view addSubview:webview];
    self.wkwebview = webview;
    
    [self.wkwebview addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSURLRequest *req;
                req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:testurl]];
                [self.wkwebview loadRequest:req];
        
//        NSString *script = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"bridge" ofType:@"html"] encoding:NSUTF8StringEncoding error:NULL];
//        [self.wkwebview loadHTMLString:script baseURL:nil];
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - WKNavigationDelegate

// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"%s", __FUNCTION__);
}
// 当内容开始到达时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    NSLog(@"%s", __FUNCTION__);
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"%s", __FUNCTION__);
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"%s", __FUNCTION__);
}


//收到服务器重定向请求后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"%s", __FUNCTION__);
}
// 在收到响应开始加载后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    NSLog(@"%s", __FUNCTION__);
    
    decisionHandler(WKNavigationResponsePolicyAllow);
}
// 在请求开始加载之前调用，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView evaluateJavaScript:@"var a = document.getElementsByTagName('a');for(var i=0;i<a.length;i++){a[i].setAttribute('target','');}" completionHandler:nil];
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - WKUIDelegate

- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    NSLog(@"%s", __FUNCTION__);
    
    WKFrameInfo *frameInfo = navigationAction.targetFrame;
    if (![frameInfo isMainFrame]) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}
// 在js中调用alert函数时，会调用该方法。
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    NSLog(@"%s", __FUNCTION__);
    completionHandler();
}
// 在js中调用confirm函数时，会调用该方法
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    NSLog(@"%s", __FUNCTION__);
}
// 在js中调用prompt函数时，会调用该方法
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    NSLog(@"%s", __FUNCTION__);
}

#pragma mark - WKScriptMessageHandler

//获取js传递的数据
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    NSLog(@"%s", __FUNCTION__);
    
    NSLog(@"方法名:%@",message.name);
    NSLog(@"内容:%@",message.body);
    
    [self.wkwebview evaluateJavaScript:@"sendMsgToOCCallback()" completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"ok");
        }
    }];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        //NSLog(@"%@", change);
    }
}

- (void)dealloc {
    [self.wkwebview removeObserver:self forKeyPath:@"estimatedProgress"];
}

@end

