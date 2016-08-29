//
//  ViewController.m
//  NSURLSession下载文件
//
//  Created by mac on 16/8/29.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<NSURLSessionDownloadDelegate>
@property(strong,nonatomic)NSURLSession *downloadSession;
@end
/*
 问题：无法监听下载的进度
 解决：使用代理方法监听下载，必须自定义URLSession
 注意：当我们在使用NSURLSessionDownloadTask时，代理和Block不能共存，
 解决办法是，自定
 */
@implementation ViewController
//懒加载，在不知道什么时候调用时，--开发中少用，垃圾
//懒加载实例化的对象，可以保证在当前类里面，他的对象有且只有一个
//不能用self. ,死循环
-(NSURLSession *)downloadSession
{
    //开发中，一般使用默认
    NSURLSessionConfiguration  *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    if (_downloadSession == nil) {
        _downloadSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    }
    return _downloadSession;
}
- (IBAction)downloadClick4:(id)sender {
    NSURL *URL = [NSURL URLWithString:@"http://localhost/sogou.zip"];
            //NSURLSessionDataTask * downloadTask = [self.downloadSession downloadTaskWithURL:URL];
    //自定义session ，任务发起
    NSURLSessionDownloadTask *downloadTask = [self.downloadSession downloadTaskWithURL:URL];
            [downloadTask resume];
    
    
}
//监听下载进度
//bytesWtiten  :每次接收的大小
//totoalBytesWritten :已接收的总大小
//totalBytesExpectedToWrite:文件的总大小
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    
    //计算下载进度
   float   progress = (float)totalBytesWritten  / totalBytesExpectedToWrite;
    NSLog(@"下载进度%f",progress);
}
//监听文件下载完成：可以拿到缓存路径
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
//    //下载完成时，输入路径
  //  NSLog(@"%@",location.path);
    //下载完成时，及时将文件拷贝到其他
    [[NSFileManager defaultManager ]copyItemAtPath:location.path toPath:@"/Users/mac/Desktop/sogou.zip" error:NULL];
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
