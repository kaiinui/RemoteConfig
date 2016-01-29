//
//  RMTConfig.m
//  RemoteConfig
//
//  Created by kaiinui on 2016/01/29.
//  Copyright (c) 2016年 kotori. All rights reserved.
//

#import "RMTConfig.h"

@interface RMTConfig (Internal)

+ (NSString *)stringForKey:(NSString *)key;

@end

NSString *RMTString(NSString *key, NSString *defaultValue) {
    NSString *val = [RMTConfig stringForKey:key];
    if (val == nil) {
        return defaultValue;
    }
    return val;
}

NSInteger RMTInt(NSString *key, NSInteger defaultInt) {
    NSString *val = [RMTConfig stringForKey:key];
    if (val == nil) {
        return defaultInt;
    }
    return [val integerValue];
}

BOOL RMTBool(NSString *key, BOOL defaultBool) {
    NSString *val = [RMTConfig stringForKey:key];
    if (val == nil) {
        return defaultBool;
    }
    return [val boolValue];
}

static NSString *makeUserDefaultsKey(NSString *key) {
    return [@"RMTConfig_" stringByAppendingString:key];
}

static NSDictionary *mapCSVDataToDictionary(NSData *data) {
    NSMutableDictionary *keyToValue = [NSMutableDictionary dictionary];
    
    NSString *csv = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *rows = [csv componentsSeparatedByString:@"\n"];
    for (NSString *row in rows) {
        NSArray *columns = [row componentsSeparatedByString:@","];
        
        if (columns.count < 2) {
            continue;
        }
        NSString *key = columns[0];
        NSString *val = columns[1];
        
        [keyToValue setObject:val forKey:key];
    }
    
    return keyToValue.copy;
}

NSString *const kRMTConfigConfigurationRetrievedNotification = @"RMTConfigConfigurationRetrievedNotification";

static void postConfigurationRetrievedNotification() {
    [[NSNotificationCenter defaultCenter] postNotificationName:kRMTConfigConfigurationRetrievedNotification object:nil];
}

@implementation RMTConfig

+ (void)startWithURL:(NSString *)URL {
    RMTConfig *config = [self sharedInstance];
    [config startWithURL:URL];
}

+ (NSString *)stringForKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] stringForKey:makeUserDefaultsKey(key)];
}

+ (instancetype)sharedInstance {
    static RMTConfig *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[RMTConfig alloc] init];
    });
    return _instance;
}

- (void)startWithURL:(NSString *)URL {
    [self fetchCSVFromURL:[NSURL URLWithString:URL]];
}

- (void)fetchCSVFromURL:(NSURL *)URL {
    NSURLSession *sessionForFetch = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionDataTask *task = [sessionForFetch dataTaskWithURL:URL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [sessionForFetch invalidateAndCancel];
        
        if (error != nil) {
            NSLog(@"%@", error);
            return;
        }
        
        NSDictionary *keyToValue = mapCSVDataToDictionary(data);
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        
        for (NSString *key in keyToValue.allKeys) {
            if ([key rangeOfString:@"$"].location == 0) {
                continue;
            }
            [ud setObject:keyToValue[key] forKey:makeUserDefaultsKey(key)];
        }
        [ud synchronize];
        
        postConfigurationRetrievedNotification();
    }];
    [task resume];
}

@end
