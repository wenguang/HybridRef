//
//  HybridViewController.m
//  HybridRef
//
//  Created by wenguang pan on 2017/3/20.
//  Copyright © 2017年 wenguang pan. All rights reserved.
//

#import "HybridViewController.h"
#import "HybridHandler.h"
#import "HybridSetting.h"

@interface HybridViewController () <WKNavigationDelegate, HybridBridgeDelegate>

@end

@implementation HybridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    for (NSString *className in [HybridSetting sharedSetting].handlerClassNames) {
        id handler = [[NSClassFromString(className) alloc] initWithViewController:self];
        _handlerDic[className] = handler;
    }
    
    _bridge = [HybridBridge new];
    _bridge.delegate = self;
    
    _webView = [[WKWebView alloc] init];
    _webView.frame = self.view.bounds;
    _webView.navigationDelegate = self;
    [self.view addSubview:_webView];
    
    [_bridge injectHybridJS];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self startPage:@"https://www.baidu.com"];
}

#pragma mark - API

- (void)startPage:(NSString *)url {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self.webView loadRequest:request];
}

#pragma mark - WKNavigationDelegate

// 在请求开始加载之前调用，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    if (webView != _webView) { return; }
    NSURL *url = navigationAction.request.URL;
    
    if ([_bridge isHybridUrlScheme:url]) {
        if ([_bridge isLoadHybridJS:url]) {
            [_bridge injectHybridJS];
        } else if ([_bridge isJSQueueHasCommand:url]) {
            [self _fetchCommandFromJSQueue];
        } else {
            NSLog(@"Hybrid WARNING: Received unknown Hybrid command %@", [url absoluteString]);
        }
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - HybridBridgeDelegate

- (void)evaluateJavascript:(NSString *)jsCode {
    if (_webView) {
        [_webView evaluateJavaScript:jsCode completionHandler:nil];
    }
}

- (void)dispatchCommand:(HybridCommand *)command {
    for (NSString *key in self.handlerDic.allKeys) {
        if ([key isEqualToString:command.HandlerName]) {
            id handler = [self.handlerDic objectForKey:command.HandlerName];
            SEL sel = NSSelectorFromString([command.eventEvent stringByAppendingString:@":"]);
            if ([handler respondsToSelector:sel]) {
                [handler performSelector:sel withObject:command];
                break;
            }
            
        }
    }
}

#pragma mark - Private Methods

- (void)_fetchCommandFromJSQueue {
    [_webView evaluateJavaScript:[_bridge fetchCommandFromJSQueue] completionHandler:^(NSString* result, NSError* error) {
        if (error != nil) {
            NSLog(@"Hybrid WARNING: Error when trying to fetch data from WKWebView: %@", error);
        }
        [_bridge responseForJSCommand:result];
    }];
}

#pragma mark - 测试代码

- (void)callJSTest {
//    NSMutableDictionary *data = [NSMutableDictionary dictionary];
//    data[@"test"] = @"test";
//    [self.bridge callJSHandler:@"test" data:data responseCallback:^(id responseData) {
//        NSLog(@"%@", responseData);
//    }];
}

@end
