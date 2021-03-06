//
//  ViewController.m
//  RemoteConfig
//
//  Created by kaiinui on 2016/01/29.
//  Copyright (c) 2016年 kotori. All rights reserved.
//

#import "ViewController.h"
#import "RMTConfig.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"hoge" forKey:@"RMTConfig_v4.6.0=Hoge"];
    
    [RMTConfig startWithURL:@"https://rmtconfig-dot-filmappapi.appspot.com/c/default"];
    
    NSLog(@"%@", RMTString(@"GalleryPremiumBannerTitleStrin", @"whoa"));
    NSLog(@"%@", RMTString(@"SavedPhotoFreeupTitle", @"whoa"));
    
    NSLog(@"%@", [NSUserDefaults standardUserDefaults].dictionaryRepresentation);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notification:) name:kRMTConfigConfigurationRetrievedNotification object:nil];
}

- (void)notification:(NSNotification *)notif {
    NSLog(@"%@", [NSUserDefaults standardUserDefaults].dictionaryRepresentation);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
