//
//  IBaikeController.m
//  IBaikeMobile
//
//  Created by 李云天 on 10-9-7.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import "IBaikeController.h"
#import "SearchHistoryController.h"
#import "ViewImageController.h"
#import "BaiduBaike.h"
#import "BaiduBaikeHelper.h"
#import "IBaikeMobileAppDelegate.h"
#import "MsgBoxHelper.h"
#import "ReportBug.h"
#import "DownloadAndParseWebPage.h"
#import "Constants.h"
#import "MiscHelper.h"
#import "StringHelper.h"

@implementation IBaikeController
@synthesize searchResultController, searchHistoryController, savedResultController, viewImageController;
@synthesize activityIndicator, loadingView, loadingHint;
@synthesize parser, viewBaikeWebPage, baiduBaike, fromController, baikeContent, downloadPool;

#pragma mark -
#pragma mark Self API

- (void) showLoadingStatus
{	
	[activityIndicator startAnimating];
	[activityIndicator setHidden:NO];
	[loadingView setHidden:NO];
}
- (void) hideLoadingStatus
{
	[loadingView setHidden:YES];
	[activityIndicator stopAnimating];
	[activityIndicator setHidden:YES];
}

- (void) getQA
{
	[NSThread detachNewThreadSelector:@selector(showFromSearchResult) toTarget:self withObject:nil];
}

- (void) GetStarted
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	//[[AppDelegate sharedAppDelegate] didStartNetworking];

	[self showLoadingStatus];
}

- (void) GetEnded
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	[self hideLoadingStatus];
}

// 从搜索结果来
- (void) showFromSearchResult {
	self.downloadPool = [[NSAutoreleasePool alloc] init];

	[self performSelectorOnMainThread:@selector(GetStarted) withObject:nil waitUntilDone:NO];
	[self performSelectorOnMainThread:@selector(initWebView) withObject:nil waitUntilDone:NO];
	
	[BaiduBaikeHelper doGetQA:baiduBaike];
	
	[self performSelectorOnMainThread:@selector(GetEnded) withObject:nil waitUntilDone:NO];
	
	[self performSelectorOnMainThread:@selector(loadBaikeToWebPage) withObject:nil waitUntilDone:NO];
	
	[downloadPool release];
    self.downloadPool = nil;
}

// 从搜索结果来
- (void) showFromSavedResult {
	[self initWebView];
	[self loadBaikeToWebPage];
}

// 初始化WEB
- (void) initWebView
{
	[self.viewBaikeWebPage setHidden:YES];	
	[self.viewBaikeWebPage setBackgroundColor:[UIColor clearColor]];
	[self.viewBaikeWebPage loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
}

// 显示保存的资料，SavedResultController
- (void) showSavedBaikeToWebPage
{
	NSString *baikeDir = [[MiscHelper fetchSystemDir] stringByAppendingPathComponent:self.baiduBaike.baikeid];
	NSString *webpage = [NSBundle pathForResource:self.baiduBaike.baikeid ofType:@"html" inDirectory:baikeDir];  
	[viewBaikeWebPage loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:webpage]]];

	[viewBaikeWebPage setHidden:NO];

	// 用于发邮件共享
	NSString *t = [[NSString alloc] initWithContentsOfFile:webpage encoding:NSUTF8StringEncoding error:nil];
	self.baikeContent = [t stringByReplacingOccurrencesOfString:@"src=\""  withString:[NSString stringWithFormat:@"src=\"%@", kBaiduBaikeImageURLPath]];
	[t release];
}

// 载入百科内容并显示
- (void) loadBaikeToWebPage
{	
	self.baikeContent = [BaiduBaikeHelper makeBaikeWebPage:baiduBaike withFileName:@"baike.html"];
#if TARGET_IPHONE_SIMULATOR
	NSLog(@"self.baikeContent: %@", self.baikeContent);
	NSLog(@"baiduBaike.images: %@", baiduBaike.images);
#endif
	[viewBaikeWebPage loadHTMLString:self.baikeContent baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
	[viewBaikeWebPage setHidden:NO];
}

// 载入完整的百科内容并显示
- (void) loadBaikeAllToWebPage
{
	// Create the parser, set its delegate, and start it.
    self.parser = [[[DownloadAndParseWebPage alloc] init] autorelease];      
    parser.delegate = self;
	// 搜索结果列表（无法确定显示哪个条目）还是显示一个明确的条目
	parser.downloadAndParseSource = BaikePage;
	
	NSString *searchUrl = [NSString stringWithFormat:kBaiduBaikeAllViewURL, baiduBaike.baikeid, kBaiduBaikeSTParam];
    [parser start:searchUrl];
}

- (void) doSaveBaike
{
	
	self.downloadPool = [[NSAutoreleasePool alloc] init];	
	
	[self performSelectorOnMainThread:@selector(GetStarted) withObject:nil waitUntilDone:NO];
	
	@try {
		baiduBaike.pagesource = self.baikeContent;
		IBaikeMobileAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
		[BaiduBaikeHelper saveBaike:baiduBaike useDatabase:delegate.database];
		
		NSString *saved;
		if (baiduBaike.savedInDB == kSavedBaikeResultInDB) {
			saved = @"^_^，本资料已经保存过。\n\n您可以离线查看本条资料内容。";
		}
		else if (baiduBaike.savedInDB == kSavedBaikeResultYES) {
			saved = @"资料保存成功。\n\n您可以离线查看本条资料内容。";
			
			//UITabBarItem *saved = [delegate.tbc.tabBar.items objectAtIndex:0];
			//saved.badgeValue = [NSString stringWithFormat:@"%d", [BaiduBaikeHelper fetchBaikeAmount:delegate.database]];
		}
		else {
			saved = @"资料保存失败，请重试。";
		}

		[MsgBoxHelper showMsgBoxOK:saved fromDeleate:self];
	}
	@catch (NSException * e) {
		NSLog(@"%@", [e description]);
		[MsgBoxHelper showMsgBoxOK:[e description] fromDeleate:self];
	}
	@finally {
		[self.loadingHint setText:@"正在载入......"];
	}
	
	[self performSelectorOnMainThread:@selector(GetEnded) withObject:nil waitUntilDone:NO];
	
	[downloadPool release];
    self.downloadPool = nil;
}

// 将当前内容保存到数据库，以便离线浏览
- (void) saveBaike
{
	[self.loadingHint setText:@"正在保存......"];
	[NSThread detachNewThreadSelector:@selector(doSaveBaike) toTarget:self withObject:nil];
}

// 分享
- (void) shareBaike
{
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	
	NSString *subject = self.baiduBaike.baiketitle;
	NSString *body = self.baikeContent;
	
#if TARGET_IPHONE_SIMULATOR
		NSLog(@"%@", body);
#endif
	
	// We must always check whether the current device is configured for sending emails
	if (mailClass != nil && [mailClass canSendMail])
	{
		[self displayComposerSheet:subject mailBody:body];
	}
	else
	{
		[ReportBug launchMailAppOnDevice:subject mailBody:body];
	}
}

- (IBAction) moreAction
{
	NSString *save = self.baiduBaike.isBrief == 1 ? @"保存此资料的概述" : @"保存此资料全文";
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc]
								  initWithTitle:@""
								  delegate:self
								  cancelButtonTitle:@"取消"
								  destructiveButtonTitle:nil
								  otherButtonTitles:save, @"共享资料", nil];
	[actionSheet showFromToolbar:self.navigationController.toolbar];
	[actionSheet release];
}

#pragma mark -
#pragma mark UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	[self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
	//NSLog(@"willShowViewController: %@", viewController);
}
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	//NSLog(@"didShowViewController: %@", viewController);
}

#pragma mark -
#pragma mark UIActionSheetDelegate Delegate Methods
-(void)actionSheet:(UIActionSheet *) actionSheet didDismissWithButtonIndex:(NSInteger) buttonIndex
{
	switch (buttonIndex) {
		case 0:
			[self saveBaike];
			break;
		case 1:
			[self shareBaike];
			break;
		default:
			break;
	}
}

#pragma mark -
#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	//NSLog(@"%@", request.URL);
	if(navigationType ==  UIWebViewNavigationTypeLinkClicked) {
		if ([[request.URL absoluteString] isEqualToString:@"http://www.loadall.com/"]) {
			
			[self showLoadingStatus];
			
			[self loadBaikeAllToWebPage];
		}
		else if ([[request.URL absoluteString] rangeOfString:kBaiduBaikeImageURLPath].location != NSNotFound)
		{
			if (self.viewImageController == nil) {
				self.viewImageController = [[ViewImageController alloc] initWithNibName:@"ViewImage" bundle:nil];
			}
			self.viewImageController.imageUrl = request.URL;
			if (baiduBaike.savedInDB == kSavedBaikeResultInDB) {
				self.viewImageController.baikeid = self.baiduBaike.baikeid;
			}
			else {
				self.viewImageController.baikeid = @"";
			}
			
			[self.navigationController pushViewController:viewImageController animated:YES];
			[self.viewImageController showImage];
		}
		else {
			[[UIApplication sharedApplication] openURL:request.URL];
		}

		return NO;
	}
	else
	{
		return YES;
	}
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate
// Displays an email composition interface inside the application. Populates all the Mail fields. 
-(void)displayComposerSheet:(NSString *)subject mailBody:(NSString *)body
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:subject];
	
	// Set up recipients
	//NSArray *toRecipients = [NSArray arrayWithObject:kReportEmail]; 
	//[picker setToRecipients:toRecipients];
	
	//NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil]; 
	//NSArray *bccRecipients = [NSArray arrayWithObject:@"fourth@example.com"]; 	
	//[picker setCcRecipients:ccRecipients];	
	//[picker setBccRecipients:bccRecipients];
	
	/*
	 // Attach an image to the email
	 NSString *path = [[NSBundle mainBundle] pathForResource:@"rainy" ofType:@"png"];
	 NSData *myData = [NSData dataWithContentsOfFile:path];
	 [picker addAttachmentData:myData mimeType:@"image/png" fileName:@"rainy"];
	 */
	
	// Fill out the email body text
	NSString *emailBody = body;
	[picker setMessageBody:emailBody isHTML:YES];
	
	[self presentModalViewController:picker animated:YES];
    [picker release];
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	//self.fromController = @"MailComposeController";

	NSString *msg = @"";
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			//msg = @"Result: canceled";
			break;
		case MFMailComposeResultSaved:
			msg = @"邮件已经保存。";
			break;
		case MFMailComposeResultSent:
			msg = @"邮件已经发送。";
			break;
		case MFMailComposeResultFailed:
			msg = @"邮件发送失败，请稍后重试。";
			break;
		default:
			msg = @"邮件未发送，请检查您的网络环境。";
			break;
	}
	
	[self dismissModalViewControllerAnimated:YES];
	
	if (![msg isEqualToString:@""]) {
		[MsgBoxHelper showMsgBoxOK:msg fromDeleate:self];
	}
}

#pragma mark -
#pragma mark <BaiduBaikeParserDelegate> Implementation

- (void)parserDidEndParsingData:(XmlSearchResultParser *)parser
{
	baiduBaike.isBrief = 0;
	self.baikeContent = [BaiduBaikeHelper makeBaikeAllWebPage:baiduBaike withFileName:@"baikeall.html"];
#if TARGET_IPHONE_SIMULATOR
	NSLog(@"%@", self.baikeContent);
	NSLog(@"%@", baiduBaike.images);
#endif
	[viewBaikeWebPage loadHTMLString:self.baikeContent baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
	[viewBaikeWebPage setHidden:NO];
	
	[self hideLoadingStatus];
	
    self.parser = nil;
	//NSLog(@"解析完成");
	//[detailViewController.activityIndicator stopAnimating];
}
- (void)parser:(XmlSearchResultParser *)parser didParseResults:(NSArray *)results {
	BaiduBaike *_bk = [results objectAtIndex:0];
	
	self.baiduBaike.question = _bk.question;
}

- (void)parser:(XmlSearchResultParser *)parser didFailWithError:(NSError *)error {
    // handle errors as appropriate to your application...
	[MsgBoxHelper showMsgBoxOK:[error localizedDescription] fromDeleate:self];
}


#pragma mark -
#pragma mark View lifecycle
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

/*
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}
 */

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.navigationController.delegate = self;
	
	//self.title = @"百度百科";
		
	UIBarButtonItem *actionButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
																					  target:self
																					  action:@selector(moreAction)] 
										autorelease];
	
    self.navigationItem.rightBarButtonItem = actionButtonItem;
	
	[viewBaikeWebPage setHidden:YES];
	
	CGSize loadingViewSize = self.loadingView.bounds.size;
	CGRect newFrame = CGRectMake(0.00f, (self.view.bounds.size.height - loadingViewSize.height)/3, loadingViewSize.width, loadingViewSize.height);
	self.loadingView.frame = newFrame;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
	[parser release];
	
	[searchResultController release];
	[searchHistoryController release];
	[savedResultController release];
	[viewImageController release];
	
	[activityIndicator release];
	[loadingView release];
	[loadingHint release];
	
	[baiduBaike release];
	[viewBaikeWebPage release];
	
    [super dealloc];
}


@end