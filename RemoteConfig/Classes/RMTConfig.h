//
//  RMTConfig.h
//  RemoteConfig
//
//  Created by kaiinui on 2016/01/29.
//  Copyright (c) 2016年 kotori. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kRMTConfigConfigurationRetrievedNotification;

NSString *RMTString(NSString *key, NSString *defaultValue);
NSInteger RMTInt(NSString *key, NSInteger defaultInt);
BOOL RMTBool(NSString *key, BOOL defaultBool);

@interface RMTConfig : NSObject

+ (void)startWithURL:(NSString *)URL;

@end
