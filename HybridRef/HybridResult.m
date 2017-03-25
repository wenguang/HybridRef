//
//  HybridResult.m
//  HybridRef
//
//  Created by wenguang pan on 2017/3/24.
//  Copyright © 2017年 wenguang pan. All rights reserved.
//

#import "HybridResult.h"

@implementation HybridResult

+ (instancetype)resultWithStatus:(HybridResultStatus)status data:(NSDictionary *)data callbackId:(NSString *)callbackId {
    return [[HybridResult alloc] initWithStatus:status data:data callbackId:callbackId];
}

- (instancetype)initWithStatus:(HybridResultStatus)status data:(NSDictionary *)data callbackId:(NSString *)callbackId {
    if (self = [super init]) {
        _resultStatus = status;
        _resultData = data;
        _callbackId = callbackId;
    }
    return self;
}

@end
