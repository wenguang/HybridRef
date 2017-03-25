//
//  HybridHandler.m
//  HybridRef
//
//  Created by wenguang pan on 2017/3/23.
//  Copyright © 2017年 wenguang pan. All rights reserved.
//

#import "HybridHandler.h"

@implementation HybridHandler

- (instancetype)initWithViewController:(HybridViewController *)viewController {
    if (self = [super init]) {
        _viewController = viewController;
    }
    return self;
}

@end
