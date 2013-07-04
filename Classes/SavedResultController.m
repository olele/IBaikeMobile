    //
//  SavedResultController.m
//  IBaikeMobile
//
//  Created by 李云天 on 10-9-9.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import "SavedResultController.h"
#import "IBaikeMobileAppDelegate.h"
#import "BaiduBaikeHelper.h"
#import "BaiduBaike.h"
#import "IBaikeController.h"

@implementation SavedResultController

@synthesize iBaikeController, savedResults, results, searchForm;

#pragma mark -
#pragma mark Self API
- (void) showBaiduBaikePage:(UITableView *)tableView tableViewIndexPath:(NSIndexPath *)indexPath
{
	IBaikeMobileAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	
	BaiduBaike *bk = [self.savedResults objectAtIndex:indexPath.row];
	BaiduBaike *baike = [BaiduBaikeHelper fetchBaike:bk.baikeid useDatabase:delegate.database];
	baike.savedInDB = kSavedBaikeResultInDB;

	if (self.iBaikeController == nil) {
		self.iBaikeController = [[IBaikeController alloc] initWithNibName:@"IBaike" bundle:nil];
	}
	self.iBaikeController.fromController = SavedResult;
	self.iBaikeController.baiduBaike = baike;
	self.iBaikeController.title = self.iBaikeController.baiduBaike.baiketitle;
	
	[self.navigationController pushViewController:iBaikeController animated:YES];
	
	[self.iBaikeController showSavedBaikeToWebPage];
}

- (void) fetchSavedResults
{
	if (nil == self.savedResults) {
		self.savedResults = [NSMutableArray array];
	}
	else {
		[self.savedResults removeAllObjects];
	}
	
	IBaikeMobileAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	self.savedResults = [BaiduBaikeHelper fetchBaikeList:delegate.database];
	
	[self.results reloadData];
	
	//UITabBarItem *saved = [delegate.tbc.tabBar.items objectAtIndex:0];
	//saved.badgeValue = [NSString stringWithFormat:@"%d", [self.savedResults count]];
}

// Invoked when the user touches Edit.
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    // Updates the appearance of the Edit|Done button as necessary.
    [super setEditing:editing animated:animated];
    [self.results setEditing:editing animated:YES];
    // Disable the add button while editing.
	/*
    if (editing) {
        self.navbar.topItem.rightBarButtonItem.enabled = NO;
    } else {
        self.navbar.topItem.rightBarButtonItem.enabled = YES;
    }
	*/
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
    return [self.savedResults count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *SavedResultIdentifier = @"SavedResultIdentifier";
	UITableViewCell *cell = [self.results dequeueReusableCellWithIdentifier:SavedResultIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SavedResultIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		// 自动换行
		cell.textLabel.numberOfLines = 0;
	}
	
	BaiduBaike *baike = [self.savedResults objectAtIndex:indexPath.row];
	// 自动换行
	//cell.textLabel.numberOfLines = 0;
	cell.textLabel.text = [baike.baiketitle stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
	cell.detailTextLabel.text = baike.comment;
	return cell;
}

// 删除某条
- (void)tableView:(UITableView *)atableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Find the rsult at the deleted row, and remove from application delegate's array.
		IBaikeMobileAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
		
		BaiduBaike *baike = [self.savedResults objectAtIndex:indexPath.row];
		[self.savedResults removeObject:baike];
        [BaiduBaikeHelper deleteBaike:baike.baikeid useDatabase:delegate.database];
		
        // Animate the deletion from the table.
        [self.results deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark -
#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self showBaiduBaikePage:atableView tableViewIndexPath:indexPath];
}

- (void)tableView:(UITableView *)atableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	[self showBaiduBaikePage:atableView tableViewIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)atableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}

/*
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    }
    return self;
}
*/


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

//*
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self fetchSavedResults];
	
	//NSLog(@"tabBarController.selectedIndex is %d, title is %@", self.tabBarController.selectedIndex, self.title);
}
//*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];	
	
#if TARGET_IPHONE_SIMULATOR
	[self.searchForm setText:@"蜜蜂"];
#endif
	[self.searchForm setBarStyle:UIBarStyleBlack];
		
	// 导航标题
	self.title = @"存档";	
	self.navigationItem.title = @"已存百科";
	[self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
	//self.editButtonItem.title = @"删除";
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
	
	[savedResults release];
	[searchForm release];
	[results release];
	
    [super dealloc];
}


@end
