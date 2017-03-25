//
//  HybridBridge.h
//  HybridRef
//
//  Created by wenguang pan on 2017/3/20.
//  Copyright © 2017年 wenguang pan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HybridCommand.h"

#define kHybridUrlScheme      @"hybrid"
#define kJSQueueHasCommand    @"__js_queue_has_command__"
#define kLoadHybridJS         @"__load_hybrid_js__"

//typedef void (^HybridResponseCallback)(id responseData);
//typedef void (^HybridHandler)(id data, HybridResponseCallback responseCallback);

@protocol HybridBridgeDelegate <NSObject>
@required
- (void)evaluateJavascript:(NSString*)jsCode;
- (void)dispatchCommand:(HybridCommand *)command;
@end


@interface HybridBridge : NSObject

@property (weak, nonatomic)   id<HybridBridgeDelegate> delegate;

- (void)reset;

// 为webview插入Hybrid_JS
- (void)injectHybridJS;

// Hybrid URL 判断
- (BOOL)isHybridUrlScheme:(NSURL*)url;
- (BOOL)isLoadHybridJS:(NSURL*)url;
- (BOOL)isJSQueueHasCommand:(NSURL*)url;

// JS命令
- (NSString *)fetchCommandFromJSQueue;

// 调用JS Handler

- (void)responseForJSCommand:(NSString *)commandString;

@end
