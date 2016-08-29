




//
//  FileDownload.m
//  NSRULConnection下载文件
//
//  Created by mac on 16/8/29.
//  Copyright © 2016年 mac. All rights reserved.
//

/*
 问题1.内存瞬间暴涨，崩溃的几率大
 问题2.无法检测进度
 解决：使用代理方法下载
 问题3：didReceiveData 在主线程执行的，而且调用非常频繁，会卡主线程
 问题产生的原因是 
 问题4：代理方法没有提供文件的缓存机制，如果想缓存文件，必须自己实现缓存机制
 （注意：大文件已定义缓存在沙河里面，千万不能缓存在内存中
 实现沙盒缓存的策略：使用NSOutputStream 实现文件的沙盒缓存

 */
#import "FileDownload.h"
@interface FileDownload()<NSURLConnectionDataDelegate>
{
    //记录文件的总的大小
    long long _expectedLength;
    //记录文件已经下载的大小
    long long _currentLength;

    //全局额NSOutputStream
    NSOutputStream *_stream ;
    
}

@end
@implementation FileDownload
//实现文件下载的主方法
-(void)downloadWithURLString:(NSString*)URLString{
    //URL
    NSURL *URL = [NSURL URLWithString:URLString];
    //request
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    //发送异步请求
    [[[NSOperationQueue alloc ]init]addOperationWithBlock:^{
        //这个方法的调用线程和代理方法执行的是同一个线程
        [NSURLConnection connectionWithRequest:request delegate:self];
        //开启子线程，（要想代理方法能够执行，必须开启子线程的运行循环）
        [[NSRunLoop currentRunLoop]run];
       
    }];
}
//当接收到响应时调用：可以在这个方法里拿到文件的总大小和文件建议缓存的名字
-(void)connection:(NSURLConnection*)connection didReceiveResponse:(nonnull NSURLResponse *)response
{
    NSLog(@"%@",response);
    //记录文件的总大小
    _expectedLength = response.expectedContentLength;
    //建立管道
    _stream = [NSOutputStream outputStreamToFileAtPath:@"/Users/mac/Desktop/chengjingpo.zip"  append:YES];
    //开启管道
    [_stream open];
}
//服务器每次向客户端发送数据时，调用，：调用非常频繁的，不能再主线程中执行
-(void)connection:(NSURLConnection*)connection didReceiveData:(nonnull NSData *)data
{
   
  //累加每次服务器发送过来的文件的大小
    _currentLength += data.length;
    //计算进度
    float progress =(float)_currentLength /_expectedLength;
  
    NSLog(@"进度%f",progress);
    //一点一点往沙盒中存
    [_stream write:data.bytes maxLength:data.length];
  }
//文件下载完成之后调用的：可以在这个代理方法里面做文件下载完成之后的操作
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog( @"下载完成了");
    [_stream close];
    
}
@end
