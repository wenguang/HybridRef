//
//  HybridViewController.h
//  HybridRef
//
//  Created by wenguang pan on 2017/3/20.
//  Copyright © 2017年 wenguang pan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "HybridBridge.h"

@interface HybridViewController : UIViewController

@property (nonatomic, strong, readonly) WKWebView *webView;
@property (nonatomic, strong, readonly) HybridBridge *bridge;
@property (nonatomic, strong, readonly) NSMutableDictionary *handlerDic;

- (void)startPage:(NSString *)url;

@end
