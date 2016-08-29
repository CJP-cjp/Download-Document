//
//  ViewController.m
//  NSRULConnection下载文件
//
//  Created by mac on 16/8/29.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "ViewController.h"
#import "FileDownload.h"
@interface ViewController ()

@end

@implementation ViewController
//文件下载的点击事件
- (IBAction)downloadClick:(id)sender {
    //创建文件下载器
    FileDownload *dowonloader = [[FileDownload alloc]init];
    //调用下载器的下载方法
    [dowonloader downloadWithURLString:@"http://localhost/sogou.zip"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
