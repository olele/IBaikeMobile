//
//  IBaikeMobileAppDelegate.m
//  IBaikeMobile
//
//  Created by 李云天 on 10-11-10.
//  Copyright iHomeWiki 2010. All rights reserved.
//

#import "IBaikeMobileAppDelegate.h"
#import "BaiduBaikeHelper.h"
#import "MiscHelper.h"
#import "UpgradeDB.h"
#import "Constants.h"
#import "MainViewController.h"
#import "ViewImageController.h"

@implementation IBaikeMobileAppDelegate

@synthesize window, mainViewController, rootController;
@synthesize searchText, sqlite, database, systemConfig;

// 版本升级时，升级数据库
- (void) upgradeDatabase
{
	if ([UpgradeDB fetchReadableVersionNumber:nil] > [UpgradeDB fetchReadableVersionNumber:[self.systemConfig objectForKey:@"version"]]) {
		[UpgradeDB upadateDatabase:database version:[self.systemConfig objectForKey:@"version"]];
		
		// 升级后，将版本更新为当前
		[self.systemConfig setValue: [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"version"];
		
		// 压缩数据库
		[sqlite vacuumDataBase];
	}
}

// 从其他TAB搜索内容
- (void)searchQuestionsFromOtherTab:(UITabBarController *)uitbc searchText:(NSString *)str
{
	uitbc.selectedIndex = kTabBarSearchHistory;
	UINavigationController *uivc = [uitbc.viewControllers objectAtIndex:kTabBarSearchHistory];
	NSArray *views = [uivc popToRootViewControllerAnimated:NO];
	for (int i = 0; i < [views count]; i++) {
		UIViewController *v = [views objectAtIndex:i];
		v = nil;
		[v release];
	}
	SearchHistoryController *search = [uivc.viewControllers objectAtIndex:0];
	search.navigationItem.title = @"搜索";
	[search.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
	search.searchForm.text = str;
	[search doSearchTerm:str];
}

// 设置Tabbar的标题和图片
- (void) setTabbarTitleAndImage
{
	NSArray *tbcTitles = [NSArray arrayWithObjects:@"精彩", @"搜索", @"分类", @"存档", @"关于", nil];
	NSArray *tbcImages = [NSArray arrayWithObjects:@"recommended", @"searched", @"category", @"saved", @"about", nil];
	for (int i = 0; i < [self.rootController.viewControllers count] ; i++) {
		UITabBarItem *tb = [self.rootController.tabBar.items objectAtIndex:i];
		tb.title = [tbcTitles objectAtIndex:i];
		tb.image = [UIImage imageNamed:[NSString stringWithFormat:@"tb_%@.png", [tbcImages objectAtIndex:i]]];
	}
}

#pragma mark -
#pragma mark Application lifecycle
// Override point for customization after application launch.
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	if (sqlite == nil) {
		sqlite = [[SQLiteHelper alloc] init];
	}
	
	[sqlite createEditableCopyOfDatabaseIfNeeded];
	[sqlite initializeDatabase];
	database = [sqlite database];
	
	// 将文件复制到程序运行目录，以便读写
	[MiscHelper copyFileToSystemDir:@"baike.html"];
	[MiscHelper copyFileToSystemDir:@"baikeall.html"];
	[MiscHelper copyFileToSystemDir:@"style.css"];
	
	// 获取系统配置
	self.systemConfig = [MiscHelper fetchSystemConfig:database];
	//NSLog(@"%@", self.systemConfig);
	
	// 升级数据库
	//[self upgradeDatabase];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
	
	/*
	if (nil == mainViewController) {
		mainViewController = [[MainViewController alloc] initWithNibName:@"MainView" bundle:nil];
	}
	//ViewImageController *vi = [[ViewImageController alloc] initWithNibName:@"ViewImage" bundle:nil];
	[window addSubview:mainViewController.view];
	//*/
	
	[window addSubview:rootController.view];
	
	[self setTabbarTitleAndImage];
	
    [window makeKeyAndVisible];
	
	return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[rootController release];
    [window release];
    [super dealloc];
}


@end
