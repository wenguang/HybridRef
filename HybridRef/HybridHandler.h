//
//  HybridHandler.h
//  HybridRef
//
//  Created by wenguang pan on 2017/3/23.
//  Copyright © 2017年 wenguang pan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "HybridViewController.h"
#import "HybridCommand.h"

@interface HybridHandler : NSObject

@property (nonatomic, weak) HybridViewController *viewController;

- (instancetype)initWithViewController:(HybridViewController *)viewController;

@end
