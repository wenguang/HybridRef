//
//  HybridSetting.m
//  HybridRef
//
//  Created by wenguang pan on 2017/3/23.
//  Copyright © 2017年 wenguang pan. All rights reserved.
//

#import "HybridSetting.h"
#import "HybridWebHandler.h"

@implementation HybridSetting

+ (instancetype)sharedSetting {
    static HybridSetting *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [HybridSetting new];
        [sharedInstance __init];
    });
    return sharedInstance;
}

- (void)__init {
    _handlerClassNames = @[NSStringFromClass([HybridWebHandler class])];
}

@end
