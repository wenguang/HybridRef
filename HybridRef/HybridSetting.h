//
//  HybridSetting.h
//  HybridRef
//
//  Created by wenguang pan on 2017/3/23.
//  Copyright © 2017年 wenguang pan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HybridSetting : NSObject

@property (nonatomic, strong, readonly) NSArray *handlerClassNames;

+ (instancetype)sharedSetting;

@end
