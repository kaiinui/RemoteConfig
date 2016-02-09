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

/**
 *  These method do nothing on production build.
 *
 *  Force the value for `key` as given value.
 *
 *  After calling this method, `RMTString(key, someDefault)` or related methods always return forced value during the session.
 */
+ (void)debug_forceValueForKey:(NSString *)key withString:(NSString *)aString;
+ (void)debug_forceValueForKey:(NSString *)key withInt:(int)aInt;
+ (void)debug_forceValueForKey:(NSString *)key withBool:(BOOL)aBool;

@end
