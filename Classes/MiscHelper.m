//
//  MiscHelper.m
//  IBaikeMobile
//
//  Created by 李云天 on 10-9-13.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import "MiscHelper.h"
#import "UpgradeDB.h"
#import "Reachability.h"

@implementation MiscHelper

// 是否wifi
+ (BOOL)isEnableWIFI
{
	return ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != NotReachable);
}

// 是否3G
+ (BOOL)isEnable3G
{
	return ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable);
}

// 获取自1970年以来的秒数
+ (NSUInteger)getUnixTimestamp
{
	return (int) [[NSDate date] timeIntervalSince1970];
}

// 获取某个时间(2010-10-10)的UNIX时间戳
+ (NSUInteger)getUnixTimestamp:(NSString *)dateStr dateFormatter:(NSString *)formatter
{
	NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
    [df setDateFormat:formatter];
    NSDate *myDate = [df dateFromString: dateStr];
	
    return (int) [myDate timeIntervalSince1970];
}

// 获取格式化的日期：当前时间
+ (NSString *)getFormatDate:(NSString *)formatter
{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:formatter];
	
	NSString *date = [df stringFromDate:[NSDate date]];
	
	[df release];
	
	return date;
}

// 获取格式化的日期：指定时间
+ (NSString *)getFormatDate:(NSUInteger)unixTimestamp dateFormatter:(NSString *)formatter
{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:formatter];
	
	NSString *date = [df stringFromDate:[NSDate dateWithTimeIntervalSince1970:unixTimestamp]];
	
	[df release];
	
	return date;
}

// 获取格式化的日期：将某个日期(20101010)格式化为另一个格式的日期(2010年10月10日)
+ (NSString *)getFormatDate:(NSString *)dateStr fromDateFormatter:(NSString *)from toDateFormatter:(NSString *)to
{
	NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
    [df setDateFormat:from];
    NSDate *myDate = [df dateFromString: dateStr];
	
	
	NSDateFormatter *dfx = [[NSDateFormatter alloc] init];
	[dfx setDateFormat:to];
	
	NSString *date = [dfx stringFromDate:myDate];
	
	[dfx release];
	
	return date;
}

// 获取系统工作目录
+ (NSString *)fetchSystemDir
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

// 将文件从mainBundle复制到系统工作目录下
+ (void)copyFileToSystemDir:(NSString *)filename
{
    // First, test for existence.
    NSString *documentsDirectory = [MiscHelper fetchSystemDir];
    NSString *writablePath = [documentsDirectory stringByAppendingPathComponent:filename];
	
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager fileExistsAtPath:writablePath];
    if (success)
	{
		return;
	}
	
    NSError *error;
    // The file does not exist, so copy the default to the appropriate location.
    NSString *defaultPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filename];
    success = [fileManager copyItemAtPath:defaultPath toPath:writablePath error:&error];
    
	if (!success)
	{
        NSAssert1(0, @"Failed to copy file with message '%@'.", [error localizedDescription]);
    }
}

// 获取系统配置
+ (NSMutableDictionary *)fetchSystemConfig:(sqlite3 *)db
{
	NSMutableDictionary *config = [[NSMutableDictionary alloc] init];
	
	sqlite3_stmt *statement;
	
	NSUInteger errcode = -1;
	@try {
		const char *sql = "SELECT * FROM baidubaike_config";
		if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
			errcode = sqlite3_errcode(db);
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
		}

		while (sqlite3_step(statement) == SQLITE_ROW)
		{
			NSString *varname = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
			NSString *value = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			
			[config setObject:value forKey:varname];			
		}
	}
	@catch (NSException * e) {
		// 表不存在，表示是1.0.0版本，此时需要升级
		if (SQLITE_ERROR == errcode) {
			NSString *lastVersion = [UpgradeDB upadateDatabase:db version:@"1.0.0"];
			
			if (nil != lastVersion) {
				[config setObject:lastVersion forKey:@"version"];
			}
		}
	}
	
	// Finalize the statement.
	sqlite3_finalize(statement);
	
	return config;
}

// 执行SQL
+ (void)runSQL:(NSString *)sql useDatabase:(sqlite3 *)db
{
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
	}
	
	int success = sqlite3_step(statement);
	sqlite3_finalize(statement);
	
	if (success == SQLITE_ERROR) {
		NSAssert2(0, @"Error: failed to runSQL(%@) with message '%s'.", sql, sqlite3_errmsg(db));
	}
}

+ (void)runSQL:(NSString *)sql param1:(NSString *)p1 useDatabase:(sqlite3 *)db
{
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
	}
	
	sqlite3_bind_text(statement, 1, [p1 UTF8String], -1, SQLITE_TRANSIENT);	
	
	int success = sqlite3_step(statement);
	sqlite3_finalize(statement);
	
	if (success == SQLITE_ERROR) {
		NSAssert2(0, @"Error: failed to runSQL(%@) with message '%s'.", sql, sqlite3_errmsg(db));
	}
}

+ (void)runSQL:(NSString *)sql param1:(NSString *)p1 param2:(NSString *)p2 useDatabase:(sqlite3 *)db
{
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
	}
	
	sqlite3_bind_text(statement, 1, [p1 UTF8String], -1, SQLITE_TRANSIENT);	
	sqlite3_bind_text(statement, 2, [p2 UTF8String], -1, SQLITE_TRANSIENT);	
	
	int success = sqlite3_step(statement);
	sqlite3_finalize(statement);
	
	if (success == SQLITE_ERROR) {
		NSAssert2(0, @"Error: failed to runSQL(%@) with message '%s'.", sql, sqlite3_errmsg(db));
	}
}

+ (void)runSQL:(NSString *)sql param1:(NSString *)p1 param2:(NSString *)p2 param3:(NSString *)p3  useDatabase:(sqlite3 *)db
{
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
	}
	
	sqlite3_bind_text(statement, 1, [p1 UTF8String], -1, SQLITE_TRANSIENT);	
	sqlite3_bind_text(statement, 2, [p2 UTF8String], -1, SQLITE_TRANSIENT);	
	sqlite3_bind_text(statement, 3, [p3 UTF8String], -1, SQLITE_TRANSIENT);	
	
	int success = sqlite3_step(statement);
	sqlite3_finalize(statement);
	
	if (success == SQLITE_ERROR) {
		NSAssert2(0, @"Error: failed to runSQL(%@) with message '%s'.", sql, sqlite3_errmsg(db));
	}
}
@end
