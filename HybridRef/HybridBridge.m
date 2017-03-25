//
//  HybridBridge.m
//  HybridRef
//
//  Created by wenguang pan on 2017/3/20.
//  Copyright © 2017年 wenguang pan. All rights reserved.
//

#import "HybridBridge.h"
#import "Hybrid_JS.h"
#import <YYModel/YYModel.h>

#define kMaxLogLength 500

@implementation HybridBridge {
    long _uniqueId;
}

-(id)init {
    self = [super init];
    _uniqueId = 0;
    return(self);
}

- (void)dealloc {
}

- (void)reset {
    _uniqueId = 0;
}

-(NSString *)fetchCommandFromJSQueue {
    return @"hybrid._fetchCommandFromJSQueue();";
}

#pragma mark - 为webview插入Hybrid_JS

- (void)injectHybridJS {
    NSString *js = hybrid_js();
    [self _evaluateJavascript:js];
}

#pragma mark - Hybrid URL 判断

-(BOOL)isHybridUrlScheme:(NSURL*)url {
    if([[url scheme] isEqualToString:kHybridUrlScheme]){
        return YES;
    } else {
        return NO;
    }
}

-(BOOL)isLoadHybridJS:(NSURL*)url {
    return ([[url scheme] isEqualToString:kHybridUrlScheme] && [[url host] isEqualToString:kLoadHybridJS]);
}

-(BOOL)isJSQueueHasCommand:(NSURL*)url {
    if([[url host] isEqualToString:kJSQueueHasCommand]){
        return YES;
    }
    return NO;
}

#pragma mark - 调用JS & 响应从JS向获取到的消息
// 【call】
//  调用JS，分两种情况
//  1、OC端不需要回调（即responseCallback==nil），JS端处理完后就不会再调用到【response】
//  2、OC端需要回调，JS端处理完后还会调【response】，把处理结果传回给OC做回调参数
//- (void)callJSHandler:(NSString *)handlerName data:(id)data responseCallback:(HybridResponseCallback)responseCallback {
//    
//    NSMutableDictionary* messageJSON = [NSMutableDictionary dictionary];
//    if (data) {
//        messageJSON[@"data"] = data;
//    }
//    if (handlerName) {
//        messageJSON[@"handlerName"] = handlerName;
//    }
//    if (responseCallback) {
//        NSString* callbackId = [NSString stringWithFormat:@"objc_cb_%ld", ++_uniqueId];
//        //self.responseCallbacks[callbackId] = [responseCallback copy];
//        messageJSON[@"callbackId"] = callbackId;
//    }
//    
//    [self _dispatchMessageToJS:messageJSON];
//}


- (void)responseForJSCommand:(NSString *)commandString {
    
    if (commandString == nil || commandString.length == 0) {
        NSLog(@"Hybrid WARNING: ObjC got nil while fetching the command queue JSON from JS. This can happen if the Hybrid JS is not currently present in the webview, e.g if the webview just loaded a new page.");
        return;
    }
    
    id commands = [self _deserializeMessageString:commandString];
    
    for (NSDictionary* command in commands) {
        if (![command isKindOfClass:[NSDictionary class]]) {
            NSLog(@"Hybrid WARNING: Invalid %@ received: %@", [command class], command);
            continue;
        }
        [self _log:@"RCVD" json:command];
        
        HybridCommand *hybridCommand = [HybridCommand yy_modelWithJSON:command];
        if (self.delegate && [self.delegate respondsToSelector:@selector(dispatchCommand:)]) {
            [self.delegate dispatchCommand:hybridCommand];
        }
    }
}

#pragma mark - Private Methods

- (void) _evaluateJavascript:(NSString *)javascriptCommand {
    if (self.delegate && [self.delegate respondsToSelector:@selector(evaluateJavascript:)]) {
        [self.delegate evaluateJavascript:javascriptCommand];
    }
}

- (void)_dispatchMessageToJS:(NSDictionary *)messageJSON {
    NSString *messageString = [self _serializeMessageJSON:messageJSON pretty:NO];
    [self _log:@"SEND" json:messageString];
    
    //Javascript字符转义
    messageString = [self _escapeMessageString:messageString];
    
    NSString* javascriptCommand = [NSString stringWithFormat:@"hybrid._handleMessageFromObjC('%@');", messageString];
    if ([[NSThread currentThread] isMainThread]) {
        [self _evaluateJavascript:javascriptCommand];
        
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self _evaluateJavascript:javascriptCommand];
        });
    }
}

// Javascript转义字符对照表：http://tools.jb51.net/table/javascript_escape
- (NSString *)_escapeMessageString:(NSString *)messageString {
    messageString = [messageString stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    messageString = [messageString stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    messageString = [messageString stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
    messageString = [messageString stringByReplacingOccurrencesOfString:@"\b" withString:@"\\b"];   //Backspace
    messageString = [messageString stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];   //换行
    messageString = [messageString stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];   //回车
    messageString = [messageString stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];   //换页
    messageString = [messageString stringByReplacingOccurrencesOfString:@"\v" withString:@"\\v"];   //垂直制表符
    messageString = [messageString stringByReplacingOccurrencesOfString:@"\t" withString:@"\\t"];   //Tab
    messageString = [messageString stringByReplacingOccurrencesOfString:@"\u00A0" withString:@"\\u00A0"];   //不间断空格
    messageString = [messageString stringByReplacingOccurrencesOfString:@"\u2028" withString:@"\\u2028"];   //行分隔符
    messageString = [messageString stringByReplacingOccurrencesOfString:@"\u2029" withString:@"\\u2029"];   //段落分隔符
    messageString = [messageString stringByReplacingOccurrencesOfString:@"\uFEFF" withString:@"\\uFEFF"];   //字节顺序标志
    return messageString;
}

- (NSString *)_serializeMessageJSON:(id)messageJSON pretty:(BOOL)pretty{
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:messageJSON options:(NSJSONWritingOptions)(pretty ? NSJSONWritingPrettyPrinted : 0) error:nil] encoding:NSUTF8StringEncoding];
}

- (NSArray*)_deserializeMessageString:(NSString *)messageString {
    return [NSJSONSerialization JSONObjectWithData:[messageString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
}

- (void)_log:(NSString *)action json:(id)json {
    
    if (![json isKindOfClass:[NSString class]]) {
        json = [self _serializeMessageJSON:json pretty:YES];
    }
    if ([json length] > kMaxLogLength) {
        NSLog(@"Hybrid %@: %@ [...]", action, [json substringToIndex:kMaxLogLength]);
    } else {
        NSLog(@"Hybrid %@: %@", action, json);
    }
}

@end
