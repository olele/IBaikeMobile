    //
//  SearchHistoryController.m
//  IBaikeMobile
//
//  Created by 李云天 on 10-9-9.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import "SearchHistoryController.h"
#import "IBaikeMobileAppDelegate.h"
#import "BaiduBaikeHelper.h"
#import "BaiduBaike.h"
#import "MsgBoxHelper.h"
#import "Constants.h"
#import "QuestionListController.h"
#import "StringHelper.h"
#import "StringHelperExt.mm"
#import "IBaikeController.h"

@implementation SearchHistoryController

@synthesize iBaikeController, questionListController, searchHistory, searchHistoryKeys, results, searchForm, searchText;

#pragma mark -
#pragma mark Self API
// 历史
- (void) fetchSearchHistory
{
	if (nil == self.searchHistory) {
		self.searchHistory = [NSMutableDictionary dictionary];
	}
	else {
		[self.searchHistory removeAllObjects];
	}
	
	IBaikeMobileAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	NSMutableArray *histories = [BaiduBaikeHelper fetchSearchHistoryList:delegate.database];

	// 将搜索历史分组
	for (int i = 0; i < [histories count]; i++) {
		NSArray *history = [histories objectAtIndex:i];
		NSString *day = [history objectAtIndex:2];
		NSString *item = [history objectAtIndex:1]; 
		
		if (nil == [self.searchHistory objectForKey:day]) {
			[self.searchHistory setObject:[NSMutableArray arrayWithObjects:item, nil] forKey:day];
		}
		else {
			[[self.searchHistory objectForKey:day] addObject:item];
		}
	}
	
	StringHelperExt *she = new StringHelperExt();
	int reverse = YES;
	self.searchHistoryKeys = [[self.searchHistory allKeys] sortedArrayUsingFunction:she->alphabeticSort context:&reverse];

	//NSLog(@"%@", self.searchHistory);
	
	[self.results reloadData];
}

// 搜索
- (void) doSearchTerm:(NSString *)searchTerm
{
	searchTerm = [searchTerm stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	self.searchText = searchTerm;
	self.searchForm.text = searchTerm;
	
	// 保存搜索历史
	IBaikeMobileAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	[BaiduBaikeHelper saveOrUpdateSearchHistory:self.searchText useDatabase:delegate.database];
	[self fetchSearchHistory];
	
	//NSLog(@"Searching string is: %@", searchTerm);
	
	// http://wapbaike.baidu.com/search/?word=%@&st=3
	NSString *searchUrl = [BaiduBaikeHelper processSearchTermForURL:kBaiduBaikeSTParam searchTerm:searchTerm];
	
	// 搜索第一步，返回：<meta http-equiv='Pragma' content='no-cache'><meta http-equiv='Refresh'content='0;URL=/searchresult/?word=%CC%C6%B3%AF%B4%F3%CA%AB%C8%CB%C0%EE%B0%D7&st=3&uid=bd_1284428305_428&bd_page_type=1&pu=&ssid=&from='>
	// 或者：<meta http-equiv='Pragma' content='no-cache'><meta http-equiv='Refresh'content='0;URL=/view/32312312.htm?st=3&uid=bd_1284428305_428&bd_page_type=1&pu=&ssid=&from='>
	// 比如搜索“移动版”，会返回一个搜索结果列表，显示很多和移动版相关的搜索项
	// 搜索“李白”，则直接跳转到李白的详情页面
	
	NSString *searchResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:searchUrl] encoding:NSUTF8StringEncoding error:nil];

	// 未找到searchresult，表示搜索到了一个最终页面。
	if (NSNotFound == [searchResult rangeOfString:@"/searchresult/"].location) {
		
		NSString *baikeId = [BaiduBaikeHelper getBaiduBaikeId:searchResult];
		searchUrl = [NSString stringWithFormat:kBaiduBaikeViewURL, baikeId, kBaiduBaikeSTParam];
				
		// 处理并显示出来
		BaiduBaike *baike = [[BaiduBaike alloc] init];
		baike.baikeid = baikeId;
		baike.baikeurl = searchUrl;
		baike.baiketitle = searchTerm;
		
		if (self.iBaikeController == nil) {
			self.iBaikeController = [[IBaikeController alloc] initWithNibName:@"IBaike" bundle:nil];
		}
		self.iBaikeController.fromController = SearchResult;
		self.iBaikeController.baiduBaike = baike;
		self.iBaikeController.title = self.iBaikeController.baiduBaike.baiketitle;
		//NSLog(@"%@",self.iBaikeController.baiduBaike.baikeurl);
		
		[self.navigationController pushViewController:iBaikeController animated:YES];
		[self.iBaikeController getQA];
	}
	else
	{
		// 未搜索到具体页面，返回一个列表
		NSString *word = [StringHelper fetchStrBetweenTwoStr:searchResult firstString:@"?word=" secondString:@"&st="];
		searchUrl = [BaiduBaikeHelper processSearchTermForResultURL:kBaiduBaikeSTParam resultsInPage:0 searchTerm:word];

		//if (nil == self.questionListController) {
		[questionListController release];
		questionListController = nil;
		self.questionListController = [[QuestionListController alloc] init];
		self.questionListController.iBaikeController = self.iBaikeController;
		self.questionListController.questionsSource = @"SearchResult";
		//}
		self.questionListController.searchText = searchTerm;
		[self.questionListController doParse:searchUrl];
		
		// 设置百科列表View的位置
		[self.navigationController pushViewController:questionListController animated:YES];
	}
}

#pragma mark -
#pragma mark UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	if ([viewController isKindOfClass:[SearchHistoryController class]]) {
		[self fetchSearchHistory];
	}	
}

#pragma mark -
#pragma mark Search Bar Delegate Methods
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
	searchBar.showsCancelButton = YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	searchBar.showsCancelButton = NO;
	[searchBar resignFirstResponder];
	
	[self doSearchTerm:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	searchBar.showsCancelButton = NO;
	[searchBar resignFirstResponder];
}

#pragma mark -
#pragma mark Table view data source

// Return the number of sections.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return [self.searchHistory count] > 0 ? [self.searchHistory count] : 1;
}

// Return the number of rows in the section.
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	if (0 == [self.searchHistory count]) {
		return 0;
	}

	NSString *key = [self.searchHistoryKeys objectAtIndex:section];
	NSMutableArray *histories = [self.searchHistory objectForKey:key];
	
	return [histories count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *SearchHistoryIdentifier = @"SearchHistoryIdentifier";
	UITableViewCell *cell = [self.results dequeueReusableCellWithIdentifier:SearchHistoryIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SearchHistoryIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
		// 自动换行
		cell.textLabel.numberOfLines = 0;
	}
	
	NSString *key = [self.searchHistoryKeys objectAtIndex:[indexPath section]];
	NSMutableArray *histories = [self.searchHistory objectForKey:key];
	
	cell.textLabel.text = [histories objectAtIndex:indexPath.row];
		
	return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (0 == [self.searchHistory count]) {
		return @"";
	}
	
	NSString *key = [self.searchHistoryKeys objectAtIndex:section];

	return key;
}

#pragma mark -
#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *key = [self.searchHistoryKeys objectAtIndex:[indexPath section]];
	NSMutableArray *histories = [self.searchHistory objectForKey:key];
	
	self.searchForm.text = [histories objectAtIndex:indexPath.row];
	[self doSearchTerm:self.searchForm.text];
}

/*
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    }
    return self;
}
*/


// 清除搜索历史
- (IBAction) clearAction {
	[MsgBoxHelper showMsgBoxOKCancel:@"确定要清除所有的搜索历史吗？\n\n" fromDeleate:self];
}

#pragma mark -
#pragma mark UIAlertViewDelegate Delegate Methods
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if(!buttonIndex == [alertView cancelButtonIndex])
	{
		// Clear
		IBaikeMobileAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
		[BaiduBaikeHelper clearSearchHistory:delegate.database];
		
		// Reload
		[self.searchHistory removeAllObjects];
		[self.results reloadData];
	}
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
#if TARGET_IPHONE_SIMULATOR
	[self.searchForm setText:@"上海"];
#endif
	[self.searchForm setBarStyle:UIBarStyleBlack];
	
	// 导航标题
	self.title = @"搜索";	
	self.navigationItem.title = @"搜索";
	[self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
	
	UIBarButtonItem *clearButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"清空"
																		 style:UIBarButtonItemStyleBordered
																		target:self
																		action:@selector(clearAction)] 
										autorelease];
    self.navigationItem.rightBarButtonItem = clearButtonItem;
	
	self.navigationController.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self fetchSearchHistory];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
	
	[questionListController release];
	questionListController = nil;
	[iBaikeController release];
	iBaikeController = nil;
	
	[searchText release];
	searchText = nil;
	[searchHistory release];
	searchHistory = nil;
	[searchHistoryKeys release];
	searchHistoryKeys = nil;
	[searchForm release];
	searchForm = nil;
	[results release];
	results = nil;
}


- (void)dealloc {
	[questionListController release];
	[iBaikeController release];
	
	[searchText release];	
	[searchHistory release];
	[searchHistoryKeys release];
	[searchForm release];
	[results release];
	
    [super dealloc];
}


@end
