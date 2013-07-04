//
//  IBaikeController.h
//  IBaikeMobile
//
//  Created by 李云天 on 10-9-7.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "Constants.h"
#import "XmlSearchResultParser.h"

@class SearchResultController;
@class SearchHistoryController;
@class SavedResultController;
@class BaiduBaike;
@class ViewImageController;

@interface IBaikeController : UIViewController
<UIPopoverControllerDelegate, UIWebViewDelegate, MFMailComposeViewControllerDelegate, 
UIActionSheetDelegate, XmlSearchResultParserDelegate, UINavigationControllerDelegate>
{
	// 页面解析器
	XmlSearchResultParser *parser;
	
	SearchResultController *searchResultController;
	SearchHistoryController *searchHistoryController;
	SavedResultController *savedResultController;
	ViewImageController *viewImageController;
	
	UIActivityIndicatorView *activityIndicator;
	UIView *loadingView;
	UILabel *loadingHint;
	
	// UIWebView的内容从哪里来？
	UIWebViewContentSource fromController;
	
	// 知道全文，用于发送邮件分享
	NSString *baikeContent;
	// 知道
	BaiduBaike *baiduBaike;
	// 用于显示知道的web
	UIWebView *viewBaikeWebPage;
	
	NSAutoreleasePool *downloadPool;
}
@property (nonatomic, retain) XmlSearchResultParser *parser;

@property (nonatomic, retain) IBOutlet SearchResultController *searchResultController;
@property (nonatomic, retain) IBOutlet SearchHistoryController *searchHistoryController;
@property (nonatomic, retain) IBOutlet SavedResultController *savedResultController;
@property (nonatomic, retain) ViewImageController *viewImageController;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UIView *loadingView;
@property (nonatomic, retain) IBOutlet UILabel *loadingHint;

@property (nonatomic, retain) IBOutlet UIWebView *viewBaikeWebPage;

@property (nonatomic, assign) UIWebViewContentSource fromController;
@property (nonatomic, retain) NSString *baikeContent;
@property (nonatomic, retain) BaiduBaike *baiduBaike;

// The autorelease pool property is assign because autorelease pools cannot be retained.
@property (nonatomic, assign) NSAutoreleasePool *downloadPool;

// 下载知道
- (void) getQA;
// 从搜索结果来
- (void) showFromSavedResult;
// 初始化WEB
- (void) initWebView;
// 显示保存的资料
- (void) showSavedBaikeToWebPage;
// 载入知道内容并显示
- (void) loadBaikeToWebPage;
// 载入完整的百科内容并显示
- (void) loadBaikeAllToWebPage;
// 将当前内容保存到数据库，以便离线浏览
- (void) saveBaike;
// 分享
- (void) shareBaike;

// 发送邮件
- (void) displayComposerSheet:(NSString *)subject mailBody:(NSString *)body;
@end
