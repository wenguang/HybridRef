//
//  Hybrid_JS.m
//  HybridRef
//
//  Created by wenguang pan on 2017/3/20.
//  Copyright © 2017年 wenguang pan. All rights reserved.
//

#import "Hybrid_JS.h"

NSString * hybrid_js() {
#define __hybrid_js_func__(x) #x
    
    // BEGIN preprocessorJSCode
    static NSString * preprocessorJSCode = @__hybrid_js_func__(
                                                             ;(function() {
        if (window.hybrid) {
            return;
        }
        
        if (!window.onerror) {
            window.onerror = function(msg, url, line) {
                console.log("Hybrid ERROR:" + msg + "@" + url + ":" + line);
            }
        }
        window.hybrid = {
            registerHandler: registerHandler,
            callObjCHandler: callObjCHandler,
            _fetchCommandFromJSQueue: _fetchCommandFromJSQueue,
            _handleMessageFromObjC: _handleMessageFromObjC
        };
        
        var innerIframe;
        var commandQueue = [];
        var messageHandlers = {};
        
        var HYBRID_SCHEME = 'hybrid_scheme';
        var JS_QUEUE_HAS_COMMAND = '__js_queue_has_command__';
    
        function registerHandler(handlerName, handler) {
            messageHandlers[handlerName] = handler;
        }
        
        function callObjCHandler(handlerName, data, responseCallback) {
            if (arguments.length == 2 && typeof data == 'function') {
                responseCallback = data;
                data = null;
            }
            _doSend({ handlerName:handlerName, data:data }, responseCallback);
        }
        
        function _doSend(message, responseCallback) {
            if (responseCallback) {
                var callbackId = 'js_cb_'+(uniqueId++);
                responseCallbacks[callbackId] = responseCallback;
                message['callbackId'] = callbackId;
            }
            commandQueue.push(message);
            innerIframe.src = HYBRID_SCHEME + '://' + JS_QUEUE_HAS_COMMAND;
        }
        
        function _fetchCommandFromJSQueue() {
            var commandString = JSON.stringify(commandQueue);
            commandQueue = [];
            return commandString;
        }
        
        function _handleMessageFromObjC(messageJSON) {
            
            var message = JSON.parse(messageJSON);
            var messageHandler;
            var responseCallback;
            
            if (message.responseId) {
                responseCallback = responseCallbacks[message.responseId];
                if (!responseCallback) {
                    return;
                }
                responseCallback(message.responseData);
                delete responseCallbacks[message.responseId];
            } else {
                if (message.callbackId) {
                    var callbackResponseId = message.callbackId;
                    responseCallback = function(responseData) {
                        _doSend({ handlerName:message.handlerName, responseId:callbackResponseId, responseData:responseData });
                    };
                }
                
                var handler = messageHandlers[message.handlerName];
                if (!handler) {
                    console.log("Hybrid WARNING: no handler for message from ObjC:", message);
                } else {
                    handler(message.data, responseCallback);
                }
            }
        }
        
        innerIframe = document.createElement('iframe');
        innerIframe.style.display = 'none';
        innerIframe.src = HYBRID_SCHEME + '://' + JS_QUEUE_HAS_MESSAGE;
        document.documentElement.appendChild(innerIframe);
        
        
        
        //        var JS_QUEUE_HAS_COMMAND = '__js_queue_has_command__';
        //        var JS_QUEUE_HAS_RESULT  = '__js_queue_has_result__';
        //
        //        var responseCallbacks = {};
        //        var uniqueId = 1;
        //
        //        //向native发命令
        //        var commandQueue = [];
        //
        //        function sendCommandToNative(command) {
        //            if (command['commandId'])
        //        }
        //
        //        //向native发结果
        //        var resultQueue = [];
        //        
        //        //接收native的命令
        //        
        //        //接收native的结果
        
        
    })();
                                                             ); // END preprocessorJSCode
    
#undef __hybrid_js_func__
    return preprocessorJSCode;
};
