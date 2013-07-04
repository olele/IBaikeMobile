    //
//  RecommendedQuestionController.m
//  IBaikeMobile
//
//  Created by 李云天 on 10-10-12.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import "RecommendedQuestionController.h"
#import "IBaikeMobileAppDelegate.h"
#import "BaiduBaikeHelper.h"
#import "BaiduBaike.h"
#import "IBaikeController.h"
#import "MiscHelper.h"
#import "StringHelper.h"
#import "StringHelperExt.mm"
#import "SearchHistoryController.h"

@implementation RecommendedQuestionController

@synthesize iBaikeController, results, searchForm, baiduBaikeRecommend, hasInternetConnection;

#pragma mark -
#pragma mark Self API
- (void) showBaiduBaikePage:(UITableView *)tableView tableViewIndexPath:(NSIndexPath *)indexPath
{
	BaiduBaike *baike = [self.baiduBaikeRecommend.questions objectAtIndex:[indexPath row]];

	if (self.iBaikeController == nil) {
		self.iBaikeController = [[IBaikeController alloc] initWithNibName:@"IBaike" bundle:nil];
	}
	self.iBaikeController.fromController = RecommendQuestions;
	self.iBaikeController.baiduBaike = baike;
	self.iBaikeController.title = self.iBaikeController.baiduBaike.baiketitle;
	
	[self.navigationController pushViewController:self.iBaikeController animated:YES];
	
	[self.iBaikeController getQA];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	return [self.baiduBaikeRecommend.questions count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *RecommendIdentifier = @"RecommendIdentifier";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RecommendIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:RecommendIdentifier] autorelease];
		//cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	}

	BaiduBaike *baike = [self.baiduBaikeRecommend.questions objectAtIndex:[indexPath row]];
	cell.textLabel.text = [baike.baiketitle stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
	cell.detailTextLabel.text = baike.comment;
	
	return cell;
}

#pragma mark -
#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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

#if TARGET_IPHONE_SIMULATOR
	[self.searchForm setText:@"唐朝大诗人李白"];
#endif
	[self.searchForm setBarStyle:UIBarStyleBlack];
	
	// 导航标题
	self.title = @"精彩";
	self.navigationItem.title = @"精彩推荐";
	[self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
	
	// 是否有网络链接：WIFI和3G其中一个可以使用
	self.hasInternetConnection = [MiscHelper isEnable3G] || [MiscHelper isEnableWIFI];
	
	// 当有网络链接时，才可以显示精彩推荐
	if (self.hasInternetConnection)
	{
		// 获取今天的精彩推荐
		IBaikeMobileAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
		self.baiduBaikeRecommend = [BaiduBaikeHelper fetchRecommendBaike:delegate.database];	
		//NSLog(@"%@", self.baiduBaikeRecommend);
	}
	else {
		self.baiduBaikeRecommend = [[BaiduBaikeRecommend alloc] init];
		[self.results setHidden:YES];
		
		UILabel *noInternetConnection = [[UILabel alloc] init];
		noInternetConnection.text = @"似乎已断开与互联网的连接。";
		noInternetConnection.textAlignment = UITextAlignmentCenter;
		noInternetConnection.frame = CGRectMake(0, 0, 320.f, 320.0f);
		[self.view addSubview:noInternetConnection];
	}
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
	[iBaikeController release];
	iBaikeController = nil;
	[searchForm release];
	searchForm = nil;
	[results release];
	results = nil;
	
	[baiduBaikeRecommend release];
	baiduBaikeRecommend = nil;
}


- (void)dealloc {
	[iBaikeController release];
	[searchForm release];
	[results release];
	
	[baiduBaikeRecommend release];
	
    [super dealloc];
}


@end
