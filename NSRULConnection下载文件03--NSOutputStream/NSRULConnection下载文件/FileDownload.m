




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
    //文件缓存路径
    NSString *_filePath ;
    //全局的connection
    NSURLConnection *_connection;
}
//定义下载成功的successBlock属性
@property(copy,nonatomic)void(^successBlock)(NSString*filePath);
//定义下载进度的progressBlock属性
@property(copy,nonatomic)void(^progressBlock)(float progress);
//定义全局的目的地址URLString
@property(copy,nonatomic)NSString *URLString;
@end
@implementation FileDownload
//重写main方法
-(void)main
{
       //URL
      NSURL *URL = [NSURL URLWithString:_URLString];
    //最终的目的是在代理方法执行之前告诉服务器该从第几个字节开始下载数据
    _expectedLength = [self getServerFileSizeWith:URL];
    //获取本地文件的大小
    _currentLength = [self getLocalFileSizeAndCompareWithServerFileSize];
    //判断文件是否下载完成
    if (_currentLength == -888) {
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
               //回调
              _successBlock(_filePath);
            
           }];
        
        return;
    }
    //request：默认是GET
    NSMutableURLRequest *requestM = [NSMutableURLRequest requestWithURL:URL];
    
    //告诉服务器从第几个字段发送数据
    NSString *bytes = [NSString stringWithFormat:@"bytes=%lld-",_currentLength ];
    [requestM setValue:bytes forHTTPHeaderField:@"Range"];
    //发送异步请求
    [[[NSOperationQueue alloc ]init]addOperationWithBlock:^{
        //这个方法的调用线程和代理方法执行的是同一个线程
        _connection =   [NSURLConnection connectionWithRequest:requestM delegate:self];
        //开启子线程，（要想代理方法能够执行，必须开启子线程的运行循环）
        [[NSRunLoop currentRunLoop]run];
    }];

}
//暂停操作的主方法
-(void)paseload
{
    //取消下载
    [_connection cancel];
    NSLog(@"暂停下载");
    
}
//实现文件下载的主方法--先于main执行
-(void)downloadWithURLString:(NSString*)URLString successBlock:(void (^)(NSString *))sucessBlock progressBlock:(void (^)(float))progressBlock

{
    //使用这个的原因是，多个操作要在子线程程中进行（这个方法是在主线程中进行的），又要按顺序执行，故用dispatch_async异步开启子线程，{}可以满足顺序执行，（可参考同步线程的作用）
    //问题是：下载过程中，取消运行，再运行时，不是按照取消前的点开始下载的，故取消这个方法，改用自定义NSOperation ，放到main中进行
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//       
//    });
    //记录外界传入的block
    _successBlock = sucessBlock;
    _progressBlock = progressBlock;
    _URLString = URLString;
}
//获取服务器文件的总大小
-(long long)getServerFileSizeWith:(NSURL*)URL
{
    //创建请求对象
    NSMutableURLRequest *requestM = [NSMutableURLRequest requestWithURL:URL];
    //设置请求方法
    requestM.HTTPMethod = @"HEAD";
    //定义响应
    NSURLResponse *response;
    //发送同步请求
    [NSURLConnection sendSynchronousRequest:requestM returningResponse:&response error:NULL];
    //获取建议缓存的文件名，然后拼接成缓存路径
    _filePath = [NSString stringWithFormat:@"/Users/mac/Desktop/%@",response.suggestedFilename];
    //返回服务器上要传送的文件的总的大小
    return response.expectedContentLength;
}
//获取本地文件总的大小的主方法
 //NSFileManager：专门做文件的创建，删除，拷贝，获取文件的总大小
-(long long )getLocalFileSizeAndCompareWithServerFileSize
{
    long long result = 0;
    //获取文件管理者
    NSFileManager * fileManager = [NSFileManager defaultManager];
    //先判断文件是否存在
    if ([fileManager fileExistsAtPath:_filePath]) {
        //获取文件的属性
        NSDictionary *attrs =[fileManager attributesOfItemAtPath:_filePath error:NULL];
        //获取本地文件的总大小
        long long localFileSize = attrs.fileSize;
        //如果本地文件大于服务器文件
        if (localFileSize > _expectedLength) {
            [fileManager removeItemAtPath:_filePath error:nil];
            //从0开始下载
            result = 0;
        }
        //如果本地文件==服务器文件==文件已经正确下载完成了
        if (localFileSize == _expectedLength) {
            //'-888'：是一个特殊的标记，记录文件已经正确的下载完成
            result = -888;
        }
        //如果本地文件<服务器文件==接着下载
        if (localFileSize <_expectedLength) {
            result = localFileSize;
        }
    }
    return result;
}
//当接收到响应时调用：可以在这个方法里拿到文件的总大小和文件建议缓存的名字
-(void)connection:(NSURLConnection*)connection didReceiveResponse:(nonnull NSURLResponse *)response
{
    //创建管道
    _stream = [NSOutputStream outputStreamToFileAtPath:_filePath  append:YES];
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
    //实时的把下载进度回调给控制器
    if (self.progressBlock) {
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            self.progressBlock(progress);
        }];
    }
    //一点一点往沙盒中存
    [_stream write:data.bytes maxLength:data.length];
  }
//文件下载完成之后调用的：可以在这个代理方法里面做文件下载完成之后的操作
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog( @"下载完成了");
    //文件下载完成后，把路径回调给控制器
    if (self.successBlock ) {
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
           
            self.successBlock(_filePath);
        }];
    }
    //关闭管道
    [_stream close];
    
}
@end
