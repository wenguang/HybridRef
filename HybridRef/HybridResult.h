//
//  HybridResult.h
//  HybridRef
//
//  Created by wenguang pan on 2017/3/24.
//  Copyright © 2017年 wenguang pan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, HybridResultStatus)
{
    HybridResultStatusOK,
    HybridResultStatusOther
};

@interface HybridResult : NSObject

@property (nonatomic, assign, readonly) HybridResultStatus resultStatus;
@property (nonatomic, strong, readonly) NSDictionary *resultData;
@property (nonatomic, copy, readonly) NSString *callbackId;

+ (instancetype)resultWithStatus:(HybridResultStatus)status data:(NSDictionary *)data callbackId:(NSString *)callbackId;

- (instancetype)initWithStatus:(HybridResultStatus)status data:(NSDictionary *)data callbackId:(NSString *)callbackId;

@end
