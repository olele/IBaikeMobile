//
//  MiscHelper.h
//  IBaikeMobile
//
//  Created by 李云天 on 10-9-13.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface MiscHelper : NSObject {

}

// 是否wifi
+ (BOOL)isEnableWIFI;
// 是否3G
+ (BOOL)isEnable3G;

// 获取自1970年以来的秒数
+ (NSUInteger)getUnixTimestamp;
// 获取某个时间(2010-10-10)的UNIX时间戳
+ (NSUInteger)getUnixTimestamp:(NSString *)dateStr dateFormatter:(NSString *)formatter;
// 获取格式化的日期：当前时间
+ (NSString *)getFormatDate:(NSString *)formatter;
// 获取格式化的日期：指定时间
+ (NSString *)getFormatDate:(NSUInteger)unixTimestamp dateFormatter:(NSString *)formatter;
// 获取格式化的日期：将某个日期(20101010)格式化为另一个格式的日期(2010年10月10日)
+ (NSString *)getFormatDate:(NSString *)dateStr fromDateFormatter:(NSString *)from toDateFormatter:(NSString *)to;

// 获取系统工作目录
+ (NSString *)fetchSystemDir;
// 将文件从mainBundle复制到系统工作目录下
+ (void)copyFileToSystemDir:(NSString *)filename;
// 获取系统配置
+ (NSMutableDictionary *)fetchSystemConfig:(sqlite3 *)db;

// 执行SQL
+ (void)runSQL:(NSString *)sql useDatabase:(sqlite3 *)db;
+ (void)runSQL:(NSString *)sql param1:(NSString *)p1 useDatabase:(sqlite3 *)db;
+ (void)runSQL:(NSString *)sql param1:(NSString *)p1 param2:(NSString *)p2 useDatabase:(sqlite3 *)db;
+ (void)runSQL:(NSString *)sql param1:(NSString *)p1 param2:(NSString *)p2 param3:(NSString *)p3  useDatabase:(sqlite3 *)db;
@end
