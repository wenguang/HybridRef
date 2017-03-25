//
//  HybridCommand.h
//  HybridRef
//
//  Created by wenguang pan on 2017/3/24.
//  Copyright © 2017年 wenguang pan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HybridCommand : NSObject

@property (nonatomic, copy) NSString *HandlerName;
@property (nonatomic, copy) NSString *eventEvent;
@property (nonatomic, strong) NSDictionary *argments;
@property (nonatomic, copy) NSString *callbackId;

@end
