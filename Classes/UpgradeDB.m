//
//  UpgradeDB.m
//  IBaikeMobile
//
//  Created by 李云天 on 10-9-29.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import "UpgradeDB.h"
#import "MiscHelper.h"

@implementation UpgradeDB

+ (NSString *) upadateDatabase:(sqlite3 *)db version:(NSString *)preVersion
{
	NSString *lastVersion = nil;
	
	NSArray *versions = [NSArray arrayWithObjects:@"1.0.0", @"1.1.0", nil];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	NSUInteger preVer = [UpgradeDB fetchReadableVersionNumber:preVersion];
	
	for (NSString *v in versions) {
		NSUInteger vn = [UpgradeDB fetchReadableVersionNumber:v];

		if (vn <= preVer) {
			continue;
		}
		
		lastVersion = v;
		
		// 升级 upgrade_vn
		NSString *schemaFile = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"upgrade_%d", vn] ofType:nil];
		BOOL success = [fileManager fileExistsAtPath:schemaFile];
		if (!success)
		{
			continue;
		}
		// 获取文件内容
		NSData *data = [fileManager contentsAtPath:schemaFile];
		NSString *schema = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		schema = [schema stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
		schema = [schema stringByReplacingOccurrencesOfString:@"\n" withString:@""];
		
		NSArray *sqls = [schema componentsSeparatedByString:@";"];
		for (NSString *sql in sqls) {
			if ([sql isEqualToString:@""]) {
				continue;
			}
			//NSLog(@"%@", sql);
			
			[MiscHelper runSQL:sql useDatabase:db];
		}
		
		[MiscHelper runSQL:@"UPDATE baidubaike_config SET value = ? WHERE varname = 'version'" param1:v useDatabase:db];
	}
	
	return lastVersion;
}

+ (NSUInteger) fetchReadableVersionNumber:(NSString *)version
{
	if (nil == version) {
		version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];	
	}

	NSArray *arr = [version componentsSeparatedByString:@"."];
	
	NSUInteger c = [arr count];
	NSUInteger rv = 0;
	
	NSUInteger i = 0;
	for (NSString *v in arr)
	{
		i++;
		rv += [v intValue] * pow(10, (c - i) * 2);
	}
	return rv;
}
@end
