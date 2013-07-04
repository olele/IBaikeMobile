//
//  IBaikeMobileAppDelegate.h
//  IBaikeMobile
//
//  Created by 李云天 on 10-11-10.
//  Copyright iHomeWiki 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SQLiteHelper.h"

@class MainViewController;

@interface IBaikeMobileAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	MainViewController *mainViewController;
	UITabBarController *rootController;
	
	// 数据库处理
	SQLiteHelper *sqlite;
	sqlite3 *database;
	
	// 搜索内容，用于其他TAB搜索时，切换到搜索TAB
	NSString *searchText;
	
	// 系统配置
	NSMutableDictionary *systemConfig;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MainViewController *mainViewController;
@property (nonatomic, retain) IBOutlet UITabBarController *rootController;

@property (nonatomic, retain) NSString *searchText;

@property (nonatomic, retain) SQLiteHelper *sqlite;
@property (nonatomic) sqlite3 *database;

@property (nonatomic, retain) NSMutableDictionary *systemConfig;

// 版本升级时，升级数据库
- (void)upgradeDatabase;

// 从其他TAB搜索内容
- (void)searchQuestionsFromOtherTab:(UITabBarController *)uitbc searchText:(NSString *)str;

@end

