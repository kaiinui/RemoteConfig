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
    
    [RMTConfig startWithURL:@"https://docs.google.com/spreadsheets/d/1NanRTook1EeXpfIbVNR-tmGSo9h-2LSsdxJQE3n7NYM/pub?gid=0&single=true&output=csv"];
    
    NSInteger val = RMTInt(@"hoge", 2);
    NSLog(@"%ld", val + 2);
    
    BOOL yesOrNo = RMTBool(@"hoges", NO);
    NSLog(@"%ld", yesOrNo);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
