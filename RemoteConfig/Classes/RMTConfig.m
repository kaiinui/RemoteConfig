//
//  RMTConfig.m
//  RemoteConfig
//
//  Created by kaiinui on 2016/01/29.
//  Copyright (c) 2016年 kotori. All rights reserved.
//

#import "RMTConfig.h"

#define RMTLog(...) NSLog(@"RemoteConfig: %@", [NSString stringWithFormat:__VA_ARGS__]);

@interface RMTConfig ()

+ (NSString *)stringForKey:(NSString *)key;

@property (atomic) NSLock *debug_lockForForcingValues;
@property (atomic) NSMutableDictionary *debug_forcingValues;

@end

NSString *RMTString(NSString *key, NSString *defaultValue) {
    NSString *val = [RMTConfig stringForKey:key];
    if (val == nil) {
        RMTLog(@"Returning default value: %@ for key: %@", defaultValue, key);
        return defaultValue;
    }
    return val;
}

NSInteger RMTInt(NSString *key, NSInteger defaultInt) {
    NSString *val = [RMTConfig stringForKey:key];
    if (val == nil) {
        RMTLog(@"Returning default value: %ld for key: %@", defaultInt, key);
        return defaultInt;
    }
    return [val integerValue];
}

BOOL RMTBool(NSString *key, BOOL defaultBool) {
    NSString *val = [RMTConfig stringForKey:key];
    if (val == nil) {
        RMTLog(@"Returning default value: %d for key: %@", defaultBool, key);
        return defaultBool;
    }
    return [val boolValue];
}

static NSString *RMTMakeUserDefaultsKey(NSString *key) {
    return [@"RMTConfig_" stringByAppendingString:key];
}

/**
 *  @return `RMTConfig_v3.5.6=SomeKey`
 */
static NSString *RMTMakeUserDefaultsKeyWithVersion(NSString *key, NSString *version) {
    return [NSString stringWithFormat:@"RMTConfig_v%@=%@", version, key];
}

static NSDictionary *RMTMapCSVDataToDictionary(NSData *data) {
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
        
        if (key == nil || val == nil) {
            continue;
        }
        
        [keyToValue setObject:val forKey:key];
    }
    
    return keyToValue.copy;
}

NSString *const kRMTConfigConfigurationRetrievedNotification = @"RMTConfigConfigurationRetrievedNotification";

static void postConfigurationRetrievedNotification() {
    [[NSNotificationCenter defaultCenter] postNotificationName:kRMTConfigConfigurationRetrievedNotification object:nil];
}

static void RMTRemoveVersionSpecifiedValuesFromUserDefaults(NSUserDefaults *ud) {
    for (NSString *key in ud.dictionaryRepresentation.allKeys) {
        if ([key rangeOfString:@"RMTConfig_v"].location == NSNotFound) { continue; }
        
        [ud removeObjectForKey:key];
    }
}

static NSURL *RMTAppendQueryStringToURL(NSURL *URL, NSString *queryString) {
    NSString *urlStr = URL.absoluteString;
    NSString *resStr = [NSString stringWithFormat:@"%@%@%@", urlStr, [urlStr rangeOfString:@"?"].length > 0 ? @"&" : @"?", queryString];
    
    return [NSURL URLWithString:resStr];
}

/**
 *  @return x.x.x style version
 */
static NSString *RMTGetAppVersion() {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

@implementation RMTConfig

# pragma mark - Public API

+ (void)startWithURL:(NSString *)URL {
    RMTConfig *config = [self sharedInstance];
    [config startWithURL:URL];
}

+ (NSString *)stringForKey:(NSString *)key {
#ifdef DEBUG
    RMTConfig *instance = [RMTConfig sharedInstance];
    [instance.debug_lockForForcingValues lock];
    NSString *forcingValue = [instance.debug_forcingValues objectForKey:key];
    [instance.debug_lockForForcingValues unlock];
    if (forcingValue != nil) {
        RMTLog(@"Returning forced value: %@ for key: %@", forcingValue, key);
        return forcingValue;
    }
#endif
    
    NSString *appVersion = RMTGetAppVersion();
    NSString *versionSpecificValue = [[NSUserDefaults standardUserDefaults] stringForKey:RMTMakeUserDefaultsKeyWithVersion(key, appVersion)];
    if (versionSpecificValue != nil) {
        RMTLog(@"Returning version specific value: %@ for key: %@", versionSpecificValue, key);
        return versionSpecificValue;
    }
    
    return [[NSUserDefaults standardUserDefaults] stringForKey:RMTMakeUserDefaultsKey(key)];
}

# pragma mark - Debugging API

+ (void)debug_forceValueForKey:(NSString *)key withString:(NSString *)aString {
    NSParameterAssert(key);
    NSParameterAssert(aString);
    
#ifdef DEBUG
    RMTLog(@"RemoteConfig: Forcing value for key: '%@' with '%@'", key, aString);
    RMTConfig *instance = [RMTConfig sharedInstance];
    [instance.debug_lockForForcingValues lock];
    [instance.debug_forcingValues setObject:aString forKey:key];
    [instance.debug_lockForForcingValues unlock];
#endif
}

+ (void)debug_forceValueForKey:(NSString *)key withInt:(int)aInt {
    [self debug_forceValueForKey:key withString:[NSString stringWithFormat:@"%d", aInt]];
}

+ (void)debug_forceValueForKey:(NSString *)key withBool:(BOOL)aBool {
    [self debug_forceValueForKey:key withInt:aBool];
}

# pragma mark - Internal

+ (instancetype)sharedInstance {
    static RMTConfig *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[RMTConfig alloc] init];
        _instance.debug_lockForForcingValues = [[NSLock alloc] init];
        _instance.debug_forcingValues = [NSMutableDictionary dictionary];
    });
    return _instance;
}

- (void)startWithURL:(NSString *)URL {
    [self fetchCSVFromURL:[NSURL URLWithString:URL]];
}

- (void)fetchCSVFromURL:(NSURL *)URL {
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
    NSURLSession *sessionForFetch = [NSURLSession sessionWithConfiguration:config];
    
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSURL *urlToFetch = RMTAppendQueryStringToURL(URL, [NSString stringWithFormat:@"rand=%ld&verson=%@", (long)arc4random(), appVersion]);
    NSURLSessionDataTask *task = [sessionForFetch dataTaskWithURL:urlToFetch completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [sessionForFetch invalidateAndCancel];
        
        if (error != nil) {
            RMTLog(@"%@", error);
            return;
        }
        
        NSDictionary *keyToValue = RMTMapCSVDataToDictionary(data);
        RMTLog(@"Receiving data: %@", keyToValue);
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        
        // `v4.6.0=SomeKey` を設定したのち `v4.6.0=SomeKey` を削除した場合、UserDefaultsには削除が反映されず結果としてv指定のあるものが優先されておかしな挙動になってしまう
        // 毎回フェッチするたびにv指定のあるものは全て削除する。
        RMTRemoveVersionSpecifiedValuesFromUserDefaults(ud);
        
        for (NSString *key in keyToValue.allKeys) {
            if ([key rangeOfString:@"$"].location == 0) {
                continue;
            }
            [ud setObject:keyToValue[key] forKey:RMTMakeUserDefaultsKey(key)];
        }
        [ud synchronize];
        
        postConfigurationRetrievedNotification();
    }];
    [task resume];
}

@end
