    //
//  AboutIBaikeController.m
//  IBaikeMobile
//
//  Created by 李云天 on 10-9-15.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import "AboutIBaikeController.h"


@implementation AboutIBaikeController

@synthesize aboutTable, aboutInfo, aboutKeys, tempUrl;

- (void)viewDidLoad {
	// 导航标题
	self.title = @"关于";
	
	// 扇区
	NSMutableArray *keys = [[NSMutableArray alloc] init];
	[keys addObject:@"aboutihomewiki_ibaike"];
	[keys addObject:@"aboutihomewiki_apps"];
	[keys addObject:@"aboutihomewiki"];
	self.aboutKeys = keys;
	keys = nil;
	[keys release];
	
	// 关于内容
	NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
	
	/* 关于家庭百科 */
	NSMutableArray *items = [[NSMutableArray alloc] init];
	
	// 版本
	NSArray * version = [NSArray arrayWithObjects:@"版本", @"1.0.0", nil];
	[items addObject:version];
	//[version release];
	
	// 网址
	NSArray * weburl = [NSArray arrayWithObjects:@"网址", @"http://www.ihomewiki.com/", nil];
	[items addObject:weburl];
	//[weburl release];
	
	// Copyright
	NSArray * copyright = [NSArray arrayWithObjects:@"版权", @"(C) 2010 iHomeWiki", nil];
	[items addObject:copyright];
	//[copyright release];
	
	[info setObject:items forKey:@"aboutihomewiki"];
	[items release];
	
	/* 关于健康系列 */
	NSMutableArray *healthItems = [[NSMutableArray alloc] init];
	
	// 版本
	NSString *sv = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];	
	NSArray * version_ibaike = [NSArray arrayWithObjects:@"版本", sv, nil];
	[healthItems addObject:version_ibaike];
	
	// 网址
	NSArray * weburl_ibaike = [NSArray arrayWithObjects:@"网址", @"http://www.ihomewiki.com/baike", nil];
	[healthItems addObject:weburl_ibaike];
	//[weburl_ibaike release];
	
	// Copyright
	NSArray * copyright_ibaike = [NSArray arrayWithObjects:@"版权", @"(C) 2010 iHomeWiki", nil];
	[healthItems addObject:copyright_ibaike];
	//[copyright_ibaike release];	
	
	[info setObject:healthItems forKey:@"aboutihomewiki_ibaike"];
	[healthItems release];
	
	/* 关于所有APP */
	NSMutableArray *appItems = [[NSMutableArray alloc] init];
	
	NSArray * app1 = [NSArray arrayWithObjects:@"393288356", @"百度知道 HD", nil];
	[appItems addObject:app1];
	
	NSArray * app2 = [NSArray arrayWithObjects:@"394072267", @"百度知道", nil];
	[appItems addObject:app2];
	
	NSArray * app3 = [NSArray arrayWithObjects:@"389516986", @"健康与保健", nil];
	[appItems addObject:app3];	
	
	NSArray * app4 = [NSArray arrayWithObjects:@"390830814", @"健康与保健 免费版", nil];
	[appItems addObject:app4];	
	
	[info setObject:appItems forKey:@"aboutihomewiki_apps"];
	[appItems release];
	// 用于输出
	self.aboutInfo = info;
	[info release];
	
    [super viewDidLoad];
}

#pragma mark -
#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	//return [keys count];
	return [aboutKeys count] > 0 ? [aboutKeys count] : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if ([aboutKeys count] == 0) {
		return 0;
	}
	
	NSString *key= [aboutKeys objectAtIndex:section];
	NSArray *nameSection = [aboutInfo objectForKey:key];
	
	return [nameSection count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
	
	NSString *key = [aboutKeys objectAtIndex:section];
	NSArray *nameSection = [aboutInfo objectForKey:key];
	
	static NSString *SectionsTableIdentifier = @"SectionsTableIdentifier";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SectionsTableIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:SectionsTableIdentifier] autorelease];
		//cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	NSArray *line = [nameSection objectAtIndex:row];
	cell.textLabel.text = [line objectAtIndex:0];
	cell.detailTextLabel.text = [line objectAtIndex:1];
	
	// 加个图标，指示可以点击
	if (@"aboutihomewiki_apps" == key) {
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.tag = [cell.textLabel.text intValue];
		cell.textLabel.text = @"";
	}
	else {
		cell.accessoryType = UITableViewCellStateDefaultMask;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	//  网址
	if ([cell.textLabel.text isEqualToString:@"网址"]) {
		cell.detailTextLabel.textColor = [UIColor blueColor];
	}
	
	return cell;
	
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if ([aboutKeys count] == 0) {
		return @"";
	}
	
	NSString *key = [aboutKeys objectAtIndex:section];
	
	NSString *sectionTitle = nil;
	
	if (key == @"aboutihomewiki") {
		sectionTitle = @"关于家庭百科";
	}
	else if (@"aboutihomewiki_apps" == key) {
		sectionTitle = @"iHomeWiki 的应用";
	}
	else if (key == @"aboutihomewiki_ibaike") {
		sectionTitle = @"关于百度百科";
	}
	else {
		sectionTitle = key;
	}
	
	return sectionTitle;
}

#pragma mark -
#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
	//如果是网址，则可以点击
	if ([cell.textLabel.text isEqualToString:@"网址"]) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc]
									  initWithTitle:@"注意，将在Safari中打开此链接。\n\n"
									  delegate:self
									  cancelButtonTitle:@"取消"
									  destructiveButtonTitle:@"确定"
									  otherButtonTitles:nil];
		//[actionSheet showInView:self.view];
		[actionSheet showFromTabBar:self.tabBarController.tabBar];
		[actionSheet release];
		
		self.tempUrl = cell.detailTextLabel.text;
	}
	
	if (cell.tag > 389516900) {
		NSString *url = [NSString stringWithFormat:@"itms://itunes.apple.com/app/id%d?mt=8", cell.tag];
		[[UIApplication sharedApplication ] openURL:[NSURL URLWithString:url]]; 
	}
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
	if (cell.tag > 389516900) {
		NSString *url = [NSString stringWithFormat:@"itms://itunes.apple.com/app/id%d?mt=8", cell.tag];
		[[UIApplication sharedApplication ] openURL:[NSURL URLWithString:url]]; 
	}
}

#pragma mark -
#pragma mark UIActionSheetDelegate Delegate Methods
-(void)actionSheet:(UIActionSheet *) actionSheet didDismissWithButtonIndex:(NSInteger) buttonIndex
{
	if(!buttonIndex == [actionSheet cancelButtonIndex])
	{
		[[UIApplication sharedApplication ] openURL:[NSURL URLWithString:self.tempUrl]]; 
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
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

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
	
	[aboutTable release];
	aboutTable = nil;
	[aboutInfo release];
	aboutInfo = nil;
	[aboutKeys release];
	aboutKeys = nil;
}


- (void)dealloc {
	[aboutTable release];
	
	[aboutInfo release];
	[aboutKeys release];
	
    [super dealloc];
}


@end
