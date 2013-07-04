//
//  QuestionListController.m
//  IBaikeMobile
//
//  Created by 李云天 on 10-9-29.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import "QuestionListController.h"
#import "IBaikeMobileAppDelegate.h"
#import "BaiduBaike.h"
#import "BaiduBaikeCategory.h"
#import "IBaikeController.h"
#import "Constants.h"
#import "BaiduBaikeHelper.h"
#import "DownloadAndParseWebPage.h"
#import "MsgBoxHelper.h"
#import "StringHelper.h"

@implementation QuestionListController

@synthesize parser, iBaikeController, searchResults, pageNumber, currentCategoryId, questionsSource, searchText;

#pragma mark -
#pragma mark Self API

//  显示某个百科内容
- (void)showBaiduBaikePage:(UITableView *)aTableView tableViewIndexPath:(NSIndexPath *)indexPath
{	
	BaiduBaike *baike = [self.searchResults objectAtIndex:indexPath.row];
	//NSLog(@"%@", baike.baikeurl);
	//NSLog(@"%@", iBaikeController);
	if ([baike.baiketitle rangeOfString:@"上一页"].location != NSNotFound)
	{
		NSUInteger pn = (self.pageNumber - 2) * kSearchResultsPerPage0;
		
		self.pageNumber --;
		
		[self fetchCategoryQuestions:self.title resultsInPage:pn];
		
	}
	else if ([baike.baiketitle rangeOfString:@"下一页"].location != NSNotFound)
	{
		NSUInteger ppn = (self.pageNumber) * kSearchResultsPerPage0;
		self.pageNumber ++;
		
		[self fetchCategoryQuestions:self.title resultsInPage:ppn];
	}
	else
	{
		if (self.iBaikeController == nil) {
			self.iBaikeController = [[IBaikeController alloc] initWithNibName:@"IBaike" bundle:nil];
		}
		self.iBaikeController.fromController = QuestionList;
		self.iBaikeController.baiduBaike = [self.searchResults objectAtIndex:indexPath.row];
		self.iBaikeController.title = self.iBaikeController.baiduBaike.baiketitle;
		//NSLog(@"%@",self.iBaikeController.baiduBaike.baikeurl);

		[self.navigationController pushViewController:iBaikeController animated:YES];
		[self.iBaikeController getQA];
	}
}

- (void) reloadTableData
{
	[self.tableView reloadData];
}

// 搜索的结果数组中添加“下一页”、“上一页”
// 搜索结果和搜索分类生成的问题列表时，上一页，下一页的链接不一样
- (void) addNextPreviousItem
{
	BaiduBaike *next = [[BaiduBaike alloc] init];
	next.baiketitle = @"下一页";
	[self.searchResults addObject:next];
	[next release];
	
	// 上一页
	if (self.pageNumber > 1) {
		BaiduBaike *prev = [[BaiduBaike alloc] init];
		prev.baiketitle = @"上一页";
		[self.searchResults addObject:prev];
		[prev release];
	}
}

// 获取某个分类下的百科
- (void) fetchCategoryQuestions:(NSString *)categoryTitle resultsInPage:(NSUInteger)pn
{
	//NSLog(@"%i", pn);
	//IBaikeMobileAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	//BaiduBaikeCategory *category = [BaiduBaikeHelper fetchCategory:categoryId useDatabase:delegate.database];
	self.title = categoryTitle;
	
	if (self.searchResults == nil) {
        self.searchResults = [NSMutableArray array];
    }
	else
	{
        [self.searchResults removeAllObjects];
    }
	self.searchResults = [BaiduBaikeHelper fetchCategoryQuestionsURLs:self.title resultsInPage:pn];

	if ([self.searchResults count] >= kSearchResultsPerPage0) {
		[self addNextPreviousItem];
	}
	
	//传递给列表
	[self reloadTableData];
}

// 创建解析器，并处理URL
- (void)doParse:(NSString *)url
{
	// Allocate the array for search result storage, or empty the results of previous parses
    if (self.searchResults == nil) {
        self.searchResults = [NSMutableArray array];
    }
	else
	{
        [self.searchResults removeAllObjects];
    }
	
	NSString *searchUrl = [url retain];

	// Create the parser, set its delegate, and start it.
    self.parser = [[[DownloadAndParseWebPage alloc] init] autorelease];      
    parser.delegate = self;
	// 搜索结果列表（无法确定显示哪个条目）还是显示一个明确的条目
	parser.downloadAndParseSource = BaikeSearchResult;
	
    [parser start:searchUrl];
	
	//传递给列表
	[self reloadTableData];
}

#pragma mark -
#pragma mark <BaiduBaikeParserDelegate> Implementation

- (void)parserDidEndParsingData:(XmlSearchResultParser *)parser
{
	// 没有找到结果
	if ([self.searchResults count] == 0)
	{
		[MsgBoxHelper showMsgBoxOK:@"未找到相关的百科资料，请输入其他关键字试一试。" fromDeleate:self];
	}
	else
	{
		self.title = self.searchText;
	}
	
	[self reloadTableData];
    self.parser = nil;
	NSLog(@"解析完成");
	//[detailViewController.activityIndicator stopAnimating];
}

- (void)parser:(XmlSearchResultParser *)parser didParseResults:(NSArray *)results {
	[self.searchResults addObjectsFromArray:results];
	
    // Three scroll view properties are checked to keep the user interface smooth during parse. 
	// When new objects are delivered by the parser, the table view is reloaded to display them. 
	// If the table is reloaded while the user is scrolling, this can result in eratic behavior. dragging, tracking, and decelerating can be checked for this purpose. 
	// When the parser finishes, reloadData will be called in parserDidEndParsingData:, 
	// guaranteeing that all data will ultimately be displayed even if reloadData is not called in this method because of user interaction.
    if (!self.tableView.dragging && !self.tableView.tracking && !self.tableView.decelerating) {
        [self reloadTableData];
    }
}

- (void)parser:(XmlSearchResultParser *)parser didFailWithError:(NSError *)error {
    // handle errors as appropriate to your application...
	[MsgBoxHelper showMsgBoxOK:[error localizedDescription] fromDeleate:self];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.searchResults count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *QuestionListIdentifier = @"QuestionListIdentifier";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:QuestionListIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:QuestionListIdentifier] autorelease];
		// 自动换行
		cell.textLabel.numberOfLines = 0;
	}
	
	BaiduBaike *baike = [searchResults objectAtIndex:indexPath.row];
	//NSString *_t = [[searchResults objectAtIndex:indexPath.row] baiketitle];
	//NSLog(@"%@", baike.baikeurl);
	cell.textLabel.text = [baike.baiketitle stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
	cell.detailTextLabel.text = baike.comment;
	
	if ([baike.baiketitle rangeOfString:@"上一页"].location != NSNotFound) {
		cell.imageView.image = [UIImage imageNamed:@"prevpage.png"];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	else if ([baike.baiketitle rangeOfString:@"下一页"].location != NSNotFound) {
		cell.imageView.image = [UIImage imageNamed:@"nextpage.png"];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	else {
		//cell.imageView.image = [UIImage imageNamed:@"blank1x1.png"];
		cell.imageView.image = nil;
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	}
	
	return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	
	[self showBaiduBaikePage:tableView tableViewIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	[self showBaiduBaikePage:tableView tableViewIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}

#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle
- (void)viewDidLoad {
	// 默认是第一页
	self.pageNumber = 1;

    [super viewDidLoad];
	
	//self.navigationItem.title = @"搜索";

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	//NSLog(@"QuestionList viewWillAppear");
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	//NSLog(@"QuestionList viewDidAppear");
}

/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[parser release];
	[iBaikeController release];
	[searchResults release];
	[searchText release];
	
    [super dealloc];
}


@end

