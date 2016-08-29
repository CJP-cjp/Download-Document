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
@property(strong,nonatomic) FileDownload *dowonloader;
@end

@implementation ViewController

- (IBAction)paseloadClick:(id)sender {
    [self.dowonloader paseload];
}


//文件下载的点击事件
- (IBAction)downloadClick:(id)sender {
   // NSLog(@"2345");
    //创建文件下载器
   _dowonloader = [[FileDownload alloc]init];
    //调用下载器的下载方法
    [_dowonloader downloadWithURLString:@"http://localhost/sogou.zip" successBlock:^(NSString *filePath) {
        NSLog(@"下载完成的路径%@",filePath);
    } progressBlock:^(float progress) {
        NSLog(@"下载进度：%f",progress);
    }];
    [[[NSOperationQueue alloc]init]addOperation:_dowonloader];
    
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
