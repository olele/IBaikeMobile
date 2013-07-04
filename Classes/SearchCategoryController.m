    //
//  SearchCategoryController.m
//  IBaikeMobile
//
//  Created by 李云天 on 10-9-28.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import "SearchCategoryController.h"
#import "IBaikeMobileAppDelegate.h"
#import "BaiduBaikeHelper.h"
#import "BaiduBaikeCategory.h"
#import "IBaikeController.h"
#import "MsgBoxHelper.h"
#import "QuestionListController.h"

@implementation SearchCategoryController

@synthesize iBaikeController, questionListController, parentIdQueue, parentTitleQueue, categories, questions, results, searchText, searchForm, isCategoryTableView;

#pragma mark -
#pragma mark self API
- (void)fetchCategories:(NSUInteger)parentId
{
	if (nil == self.categories) {
		self.categories = [NSMutableArray array];
	}
	else {
		[self.categories removeAllObjects];
	}
	
	IBaikeMobileAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	self.categories = [BaiduBaikeHelper fetchCategories:parentId useDatabase:delegate.database];
	
	[self.results reloadData];
}

// 返回上一级分类
- (IBAction) viewUpCategoryAction {
	NSUInteger count = [self.parentIdQueue count];
	NSUInteger pid = [[self.parentIdQueue objectAtIndex:count - 1] intValue];
	[self.parentIdQueue removeLastObject];

	NSString *ptitle = [self.parentTitleQueue objectAtIndex:count - 1];
	[self.parentTitleQueue removeLastObject];
	self.navigationItem.title = ptitle;

	if (0 == [self.parentIdQueue count]) {
		[self removeViewUpCategoryButton];
	}
	
	[self fetchCategories:pid];
}

// 查看下级分类时，添加返回上级的按钮
- (void) addViewUpCategoryButton {
	UIBarButtonItem *backButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"向上一级"
																		style:UIBarButtonItemStyleBordered
																	   target:self
																	   action:@selector(viewUpCategoryAction)] 
									   autorelease];
	self.navigationItem.leftBarButtonItem = backButtonItem;
}

// 移除返回上级按钮
- (void) removeViewUpCategoryButton {
	self.navigationItem.leftBarButtonItem = nil;
}

-(void) showChildren:(NSIndexPath *)indexPath
{
	BaiduBaikeCategory *category = [self.categories objectAtIndex:indexPath.row];
	
	// 显示分类是百科知识
	if (0 == category.amount)
	{
		// 百科列表
		self.isCategoryTableView = NO;
		
		BaiduBaikeCategory *category = [self.categories objectAtIndex:indexPath.row];
		
		if (nil == self.questionListController) {
			questionListController = [[QuestionListController alloc] init];
			questionListController.iBaikeController = self.iBaikeController;
			questionListController.questionsSource = @"SearchCategory";
		}
		
		[questionListController fetchCategoryQuestions:category.title resultsInPage:0];
		[self.navigationController pushViewController:questionListController animated:YES];
	}
	else
	{
		// 分类列表
		self.isCategoryTableView = YES;
		
		self.navigationItem.title = category.title;
		[self.parentIdQueue addObject:[NSString stringWithFormat:@"%d", category.parentId]];
		[self.parentTitleQueue addObject:category.title];
		
		[self addViewUpCategoryButton];	
		[self fetchCategories:category.categoryId];
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
	
	IBaikeMobileAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	[delegate searchQuestionsFromOtherTab:self.tabBarController searchText:searchBar.text];
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
    return 1;
}

// Return the number of rows in the section.
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return [self.categories count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *SearchCategoryIdentifier = @"SearchCategoryIdentifier";
	UITableViewCell *cell = [self.results dequeueReusableCellWithIdentifier:SearchCategoryIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SearchCategoryIdentifier] autorelease];
		
		// 自动换行
		//cell.textLabel.numberOfLines = 0;
	}
	
	// 生成分类列表
	BaiduBaikeCategory *category = [self.categories objectAtIndex:indexPath.row];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	cell.tag = category.categoryId;
	cell.textLabel.text = category.title;
	if (category.children == nil || [category.children isEqualToString:@""]) {
		cell.detailTextLabel.text = @"";
	}
	else {
		cell.detailTextLabel.text = category.children;
	}

	
	return cell;
}

#pragma mark -
#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self showChildren:indexPath];
}

- (void)tableView:(UITableView *)atableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{	
	[self showChildren:indexPath];
}


- (CGFloat)tableView:(UITableView *)atableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}

/*
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		UIImage *anImage = [UIImage imageNamed:@"tb_category.png"];
		UITabBarItem *theItem = [[UITabBarItem alloc] initWithTitle:@"知道分类" image:anImage tag:0];
		self.tabBarItem = theItem;
		[theItem release];
    }
    return self;
}
//*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];	
	//NSLog(@"tabBarController.selectedIndex is %d, title is %@", self.tabBarController.selectedIndex, self.title);
}
 */

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self.searchForm setBarStyle:UIBarStyleBlack];
	
	// 导航标题
	self.title = @"分类";	
	self.navigationItem.title = @"百科分类";
	[self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];

	if (nil == self.parentIdQueue) {
		self.parentIdQueue = [NSMutableArray array];
	}
	else {
		[self.parentIdQueue removeAllObjects];
	}
	
	if (nil == self.parentTitleQueue) {
		self.parentTitleQueue = [NSMutableArray array];
	}
	else {
		[self.parentTitleQueue removeAllObjects];
	}
	[self.parentTitleQueue addObject:@"分类"];
	
	if (nil == self.questions) {
		self.questions = [NSMutableArray array];
	}
	else {
		[self.questions removeAllObjects];
	}
	
	self.isCategoryTableView = YES;
	
	[self fetchCategories:0];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


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
	[iBaikeController release];
	[parentIdQueue release];
	[parentTitleQueue release];
	[categories release];
	[questions release];
	[searchText release];
	[searchForm release];
	[results release];
	
    [super dealloc];
}


@end
