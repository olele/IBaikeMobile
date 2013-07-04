    //
//  MainViewController.m
//  IBaikeMobile
//
//  Created by 李云天 on 10-10-12.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import "MainViewController.h"
#import "Constants.h"


@implementation MainViewController

@synthesize tbc, savedResultController, searchHistoryController, searchCategoryController, recommendedQuestionController, aboutIBaikeController;
@synthesize currentTab;

// 创建TabBar
- (void)createTabBar
{
	self.tbc = [[UITabBarController alloc] init];
	self.tbc.delegate = self;
	
	//*
	// 精彩推荐
	recommendedQuestionController = [[RecommendedQuestionController alloc] initWithNibName:@"RecommendQuestion" bundle:nil];
	UINavigationController *recommendedQuestionNavigationController = [[UINavigationController alloc] initWithRootViewController:recommendedQuestionController];
	[recommendedQuestionNavigationController.navigationBar setBarStyle:UIBarStyleBlack];
	
	// 搜索
	searchHistoryController = [[SearchHistoryController alloc] initWithNibName:@"SearchHistory" bundle:nil];
	UINavigationController *searchHistoryNavigationController = [[UINavigationController alloc] initWithRootViewController:searchHistoryController];
	[searchHistoryNavigationController.navigationBar setBarStyle:UIBarStyleBlack];
	
	// 分类
	searchCategoryController = [[SearchCategoryController alloc] initWithNibName:@"SearchCategory" bundle:nil];	
	UINavigationController *searchCategoryNavigationController = [[UINavigationController alloc] initWithRootViewController:searchCategoryController];
	[searchCategoryNavigationController.navigationBar setBarStyle:UIBarStyleBlack];
	
	// 保存的资料
	savedResultController = [[SavedResultController alloc] initWithNibName:@"SearchHistory" bundle:nil];	
	UINavigationController *savedResultNavigationController = [[UINavigationController alloc] initWithRootViewController:savedResultController];
	[savedResultNavigationController.navigationBar setBarStyle:UIBarStyleBlack];
	
	// 关于
	aboutIBaikeController = [[AboutIBaikeController alloc] initWithNibName:@"AboutIBaike" bundle:nil];	
	
	// 添加TabBar
	self.tbc.viewControllers = [NSArray arrayWithObjects:recommendedQuestionNavigationController, searchHistoryNavigationController, searchCategoryNavigationController, savedResultNavigationController, aboutIBaikeController, nil];
	//*/

	UITabBarItem *recommended = [self.tbc.tabBar.items objectAtIndex:kTabBarRecommendedQuestion];
	recommended.title = @"精彩";
	recommended.image = [UIImage imageNamed:@"tb_recommended.png"];
	
	UITabBarItem *result = [self.tbc.tabBar.items objectAtIndex:kTabBarSearchHistory];
	result.title = @"搜索";
	result.image = [UIImage imageNamed:@"tb_searched.png"];
	
	UITabBarItem *category = [self.tbc.tabBar.items objectAtIndex:kTabBarSearchCategory];
	category.title = @"分类";
	category.image = [UIImage imageNamed:@"tb_category.png"];
	
	UITabBarItem *saved = [self.tbc.tabBar.items objectAtIndex:kTabBarSavedResult];
	saved.title = @"存档";
	saved.image = [UIImage imageNamed:@"tb_saved.png"];
	
	UITabBarItem *about = [self.tbc.tabBar.items objectAtIndex:kTabBarAbout];
	about.title = @"关于";
	about.image = [UIImage imageNamed:@"tb_about.png"];
}

#pragma mark -
#pragma mark UITabBarControllerDelegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
#if TARGET_IPHONE_SIMULATOR
	NSLog(@"tabBarController.selectedIndex is %d", tabBarController.selectedIndex);
#endif
	// 查看图片时，此时状态栏和导航栏都有隐藏，此时点击tabbar上都按钮，显示的视图可能状态栏和导航栏不显示。
	// 因此必须显示出来
	/*
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	for(int i = 0; i< [tabBarController.viewControllers count] - 1; i++)
	{
		UINavigationController *nc = [tabBarController.viewControllers objectAtIndex:i];
		[nc.navigationBar setBarStyle:UIBarStyleBlack];
		//[nc.navigationBar setTranslucent:YES];
		[nc setNavigationBarHidden:NO animated:NO];
	}
	*/
			
	// 避免重复点击
	if (tabBarController.selectedIndex == self.currentTab) {
		return;
	}
	
	self.currentTab = tabBarController.selectedIndex;
	
	// 保存的
	if (kTabBarSavedResult == tabBarController.selectedIndex)
	{
		[self.savedResultController fetchSavedResults];
	}
	else if (kTabBarSearchHistory == tabBarController.selectedIndex) {
		// 搜索历史
		// 已经通过代理操作了。
		//[self.searchHistoryController fetchSearchHistory];
	}
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.currentTab = 0;
	
	// 创建TabBar
	[self createTabBar];
	
	[self.view addSubview:tbc.view];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[tbc release];
	[savedResultController release];	
	[searchHistoryController release];
	[searchCategoryController release];
	[recommendedQuestionController release];
	[aboutIBaikeController release];
	
    [super dealloc];
}


@end
