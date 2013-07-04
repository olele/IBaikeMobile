//
//  UpgradeDB.h
//  IBaikeMobile
//
//  Created by 李云天 on 10-9-29.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface UpgradeDB : NSObject {
	
}

// 更新数据库
+ (NSString *) upadateDatabase:(sqlite3 *)db version:(NSString *)preVersion;
// 将1.1.3转换为10103这样的数字
+ (NSUInteger) fetchReadableVersionNumber:(NSString *)version;
@end
