//
//  FileDownload.h
//  NSRULConnection下载文件
//
//  Created by mac on 16/8/29.
//  Copyright © 2016年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileDownload : NSOperation
/*
 *文件下载的主方法
 * URLString :文件下载的地址
 */
-(void)downloadWithURLString:(NSString*)URLString successBlock:(void(^)(NSString *filePath))sucessBlock progressBlock:(void(^)(float progress))progressBlock;
//暂停操作的主方法
-(void)paseload;
@end
